-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Load user modules from ~/.config and Omarchy defaults from $OMARCHY_PATH.
package.path = os.getenv("HOME")
  .. "/.config/?.lua;"
  .. (os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy"))
  .. "/?.lua;"
  .. package.path

-- All Omarchy default setups
require("default.hypr.omarchy")

-- Change your own setup in these files and override defaults.
require("hypr.envs")
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Chromium-based browsers configuration (with Chromium as fallback)

-- Force file dialogs (Save As, Open File, etc.) to open on the current workspace.
hl.window_rule({
  match = {
    title = "^(Save file|Save File|Save As|Dosya Kaydet|Farklı Kaydet|Open file|Open File|Dosya Aç|Select Folder|Klasör Seç|Upload|Karşıya Yükle).*$",
  },
  workspace = "m+0",
})

-- Waybar sistem tepsisindeki (tray) TÜM uygulamalar (Telegram, Notion, Discord, Spotify vb.) için:
-- 1) Uygulama açıksa "Show app / Göster" dendiğinde çalıştığı workspace'e otomatik odaklanılır.
-- 2) Penceresi kapalıysa (sadece tray'de bekliyorsa) pencere doğrudan mevcut aktif workspace'te açılır.
o.window(".*", { focus_on_activate = true })
o.window("org.telegram.desktop", { focus_on_activate = true })
o.window("telegram-desktop", { focus_on_activate = true })
o.window("Telegram", { focus_on_activate = true })


