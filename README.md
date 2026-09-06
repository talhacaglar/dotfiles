# Arch Linux Dotfiles

[English](#english) · [Türkçe](#türkçe)

## English

Personal Arch Linux and Hyprland configuration, package lists, and backup/restore scripts. This is a machine-specific setup, intended to be reviewed and adapted.

### Features

- Home-directory configurations, fonts, themes and icons.
- Package inventories for pacman, AUR and language-specific tools.
- Bootstrap scripts for package installation, system restore and backup.

### Getting started

Clone and inspect `install.sh`, `bootstrap/` and the package lists before using them. The installer creates links in your home directory; restore scripts also affect system configuration.

```bash
git clone https://github.com/talhacaglar/dotfiles.git
cd dotfiles
```

The reference documents package restore, symlinks, system services and manual SSH/GPG transfer. Adapt paths and hardware settings to the target machine; do not treat this snapshot as a universal installer.

[Detailed technical reference](REFERENCE.md)

## Türkçe

Kişisel Arch Linux ve Hyprland yapılandırmaları, paket listeleri ve yedekleme/geri yükleme betikleri. Makineye özel bu kurulum incelenerek ve uyarlanarak kullanılmalıdır.

### Özellikler

- Ev dizini yapılandırmaları, yazı tipleri, temalar ve simgeler.
- Pacman, AUR ve dil araçları için paket envanterleri.
- Paket kurma, sistem geri yükleme ve yedekleme için bootstrap betikleri.

### Başlangıç

Kullanmadan önce depoyu klonlayıp `install.sh`, `bootstrap/` ve paket listelerini inceleyin. Kurucu ev dizininde bağlantılar oluşturur; geri yükleme betikleri sistem yapılandırmasını da etkiler.

```bash
git clone https://github.com/talhacaglar/dotfiles.git
cd dotfiles
```

Paket geri yükleme, sembolik bağlantılar, sistem servisleri ve elle SSH/GPG aktarımı referansta açıklanır. Yolları ve donanım ayarlarını hedef makineye uyarlayın; bu anlık görüntü evrensel bir kurucu değildir.

[Ayrıntılı teknik referans](REFERENCE.md)
