function oclaude --description 'Claude Code, OmniRoute üzerinden çalışır (gerekirse OmniRoute otomatik başlatılır)'
    # OmniRoute çalışmıyorsa (port 20128 dinlenmiyorsa) arka planda başlat
    if not ss -tln 2>/dev/null | string match -q '*:20128 *'
        echo "🚀 OmniRoute başlatılıyor..."
        nohup omniroute </dev/null >/tmp/omniroute-autostart.log 2>&1 &
        disown

        # Hazır olana kadar bekle (en fazla ~20 sn)
        for i in (seq 40)
            if curl -s -o /dev/null --max-time 1 http://localhost:20128/ 2>/dev/null
                echo "✅ OmniRoute hazır (http://localhost:20128)"
                break
            end
            sleep 0.5
        end
    end

    # Kanonik form: /v1 veya /api eki YOK. Claude Code sonuna /v1/messages
    # ekler, OmniRoute da /v1/:path* -> /api/v1/:path* rewrite'ı ile karşılar.
    set -lx ANTHROPIC_BASE_URL "http://localhost:20128"
    set -lx ANTHROPIC_AUTH_TOKEN $OMNIROUTE_API_KEY

    # claude/combo/<ad>: OmniRoute'un "cc discovery alias" formu. Claude Code'un
    # model keşfi yalnızca /^(claude|anthropic)/i ile eşleşen id'leri listelediği
    # için combo'lar katalogda bu önekle yansıtılıyor; OmniRoute istekte öneki
    # soyup gerçek combo'ya yönlendiriyor. Bu yansıtma EXPOSE_CC_DISCOVERY_ALIASES
    # feature flag'ine bağlı (Dashboard -> Settings -> Feature Flags).
    # Flag kapanırsa çıplak combo adları (pro/daily/fast) da route edilir,
    # sadece /model menüsünde görünmezler.
    set -lx ANTHROPIC_MODEL "claude/combo/pro"

    # /model menüsünde OmniRoute combo'larını listele
    set -lx CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY 1

    # Alt-ajanlar (Explore/Plan vb.) ana modeli değil, "opus/sonnet/haiku"
    # katmanlarını ister ve bunlar düz claude-opus-5 gibi adlara çözülüp
    # combo dışına çıkar (yedeksiz kalır, 400/429 alır). Katmanları da
    # combo'lara eşleyerek her isteğin yedekli yoldan gitmesini sağlıyoruz.
    # DİKKAT: sonnet/haiku katmanlarını ücretli combo'lara bağlama.
    # Alt-ajanlar (Explore/Plan) sonnet katmanını ister ve çok token yakar;
    # 1. hedefi claude-opus-5 olan bir combo'ya bağlanırsa (pro/coding-paid/
    # reasoning-paid) farkında olmadan Opus kotasını tüketir. Yalnızca OPUS
    # katmanı ücretli. 2026-08-03'te providerId='claude' hedef sayımı:
    #   pro            -> 3 ücretli hedef [priority] claude-opus-5 önde (ÜCRETLİ)
    #   coding-paid    -> 2 ücretli hedef
    #   reasoning-paid -> 3 ücretli hedef
    #   pro-free       -> 0 [p2c] ücretsiz zirve, HİÇ ücretli sağlayıcı yok
    #   turbo-free     -> 0 [priority] düşük gecikmeli küçük modeller, %100 ücretsiz
    #   (long-context-free / vision / budget / coding-free / reasoning-free de 0)
    #
    # Claude Code istekleri ~49 tool taşıyor ve OmniRoute "context-aware fallback"
    # ile tool desteklemeyen hedefleri eliyor; küçük bir combo'da bu eleme ücretli
    # modeli 1. sıraya taşıyabiliyor. pro-free/turbo-free'de ücretli hedef hiç yok,
    # eleme sonrası da olamaz.
    #
    # DİKKAT: "fast" adlı bir combo KURULAMAZ. getImageModelEntry() combo
    # çözümünden önce çalışıyor ve stability-ai'nin "Fast Upscale" modeliyle
    # çakışıyor: 400 "Model 'fast' is an image-generation model...".
    # Aynı sebeple flux/chroma/sketch/style/erase/sdxl gibi adlar da rezerve.
    set -lx ANTHROPIC_DEFAULT_OPUS_MODEL "claude/combo/pro"
    set -lx ANTHROPIC_DEFAULT_SONNET_MODEL "claude/combo/pro-free"
    set -lx ANTHROPIC_DEFAULT_HAIKU_MODEL "claude/combo/turbo-free"
    set -lx ANTHROPIC_SMALL_FAST_MODEL "claude/combo/turbo-free"

    # NOT: CLAUDE_CODE_AUTO_COMPACT_WINDOW kasıtlı olarak set edilmiyor.
    # pro combo'sunun gerçek penceresi 1M ve Claude Code tanımadığı model id'leri için
    # 200K varsayıyor. Pencereyi 1M'ye açmak, context compact edilmeden büyüyeceği
    # için ücretli claude-opus-5 kotasını çok hızlı tüketir (haftalık kota ~%16).
    # Kota rahatladığında veya ücretsiz bir combo'ya sabitlenince tekrar değerlendir.

    # Nöbetçi: yukarıda eşlenen combo'lar OmniRoute kataloğunda gerçekten var mı?
    # Combo'lar dashboard'dan yeniden adlandırıldığında bu eşleşme sessizce bozulur
    # ve Claude Code ilgili katmanın HER çağrısında 404 alır — belirtisi "tool
    # kullanılamıyor / saçma çıktı" şeklinde görünür, hata olarak değil.
    # (2026-08-03: frontier→pro-free, turbo→turbo-free yeniden adlandırıldı,
    #  haiku ve sonnet katmanları günlerce 404 aldı.)
    set -l _want $ANTHROPIC_MODEL $ANTHROPIC_DEFAULT_OPUS_MODEL $ANTHROPIC_DEFAULT_SONNET_MODEL $ANTHROPIC_DEFAULT_HAIKU_MODEL $ANTHROPIC_SMALL_FAST_MODEL
    set -l _catalog (curl -s --max-time 5 -H "x-api-key: $OMNIROUTE_API_KEY" "$ANTHROPIC_BASE_URL/v1/models" 2>/dev/null | jq -r '.data[]?.id' 2>/dev/null)
    if test (count $_catalog) -gt 0
        set -l _missing
        for m in $_want
            if not contains -- $m $_catalog; and not contains -- $m $_missing
                set -a _missing $m
            end
        end
        if test (count $_missing) -gt 0
            echo "⚠️  OmniRoute kataloğunda YOK — bu katmanlar 404 alacak:"
            for m in $_missing
                echo "     ✗ $m"
            end
            echo "   Mevcut combo'lar:"
            for m in $_catalog
                string match -q 'claude/combo/*' -- $m; and echo "     · $m"
            end
            echo "   Düzelt: ~/.config/fish/functions/oclaude.fish"
            echo
        end
    end

    command claude $argv
end
