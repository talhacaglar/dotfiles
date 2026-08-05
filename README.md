# clar-dotfiles

My personal dotfiles repository for Linux (Arch-based) configuration management with complete system backup/restore capability.

## 📁 Repository Structure

```
dotfiles/
├── home/                    # Home directory dotfiles (symlinked to ~/)
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .bash_logout
│   ├── .zshrc
│   ├── .profile
│   ├── .XCompose
│   └── .gtkrc-2.0
├── config/                  # ~/.config/ directory configs (symlinked to ~/.config/)
│   ├── hypr/                # Hyprland window manager
│   ├── waybar/              # Waybar status bar
│   ├── nvim/                # Neovim configuration
│   ├── ghostty/             # Ghostty terminal
│   ├── fish/                # Fish shell
│   ├── btop/                # System monitor
│   ├── fastfetch/           # System info tool
│   ├── mako/                # Notification daemon
│   ├── walker/              # Application launcher
│   ├── gtk-3.0/             # GTK3 theme
│   ├── gtk-4.0/             # GTK4 theme
│   ├── tmux/                # Terminal multiplexer
│   ├── mimeapps.list
│   ├── environment.d/
│   ├── fontconfig/
│   └── starship.toml
├── system/                  # /etc system configurations
│   ├── pacman.conf
│   ├── mkinitcpio.conf
│   ├── grub
│   ├── pacman.d/
│   ├── modprobe.d/
│   ├── sysctl.d/
│   └── rules.d/             # udev rules
├── services/                # systemd service lists
│   ├── system-enabled.txt   # Enabled system services
│   ├── user-enabled.txt     # Enabled user services
│   └── timers.txt           # Systemd timers
├── fonts/                   # Fonts, themes, icons
│   ├── fonts/               # ~/.local/share/fonts + ~/.fonts
│   ├── themes/              # ~/.local/share/themes + ~/.themes
│   └── icons/               # ~/.local/share/icons + ~/.icons
├── bootstrap/               # System restore scripts
│   ├── install-packages.sh  # Install all packages from lists
│   ├── restore-system.sh    # Restore system configs & services
│   └── backup-system.sh     # Update backup from current system
├── pkglist-pacman.txt       # Explicit pacman packages (328)
├── pkglist-aur.txt          # AUR packages (31)
├── pkglist-npm.txt          # Global npm packages
├── pkglist-pip.txt          # Python packages
├── pkglist-cargo.txt        # Rust packages
├── pkglist-flatpak.txt      # Flatpak apps
├── install.sh               # Dotfiles symlink installer
└── .gitignore               # Git ignore rules
```

## 🚀 Complete System Restore (Fresh Install)

### Prerequisites
- Fresh Arch-based install (Arch, CachyOS, EndeavourOS, Manjaro, etc.)
- Base system installed with `base`, `linux`, `linux-firmware`, `git`, `sudo`
- User created with `wheel` group and sudo access

### Step-by-Step Restore

```bash
# 1. Clone the repository
git clone https://github.com/talhacaglar/clar-dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install ALL packages (pacman, AUR, npm, pip, cargo, flatpak)
./bootstrap/install-packages.sh

# 3. Restore system configurations (requires sudo for /etc)
sudo ./bootstrap/restore-system.sh

# 4. Symlink dotfiles to home directory
./install.sh

# 5. Import SSH/GPG keys manually (see instructions below)
# 6. Reboot
reboot
```

### What gets restored:
- ✅ All 328 pacman + 31 AUR packages
- ✅ All npm, pip, cargo packages
- ✅ System configs: `/etc/pacman.conf`, `/etc/mkinitcpio.conf`, grub, modprobe, sysctl, udev
- ✅ All enabled systemd services (system + user)
- ✅ Fonts, themes, icons
- ✅ All dotfiles (~/.config/*, ~/.*)

## 🔐 SSH / GPG Key Import (Manual - NOT in repo)

Keys are **NOT stored** in this repository for security.

### SSH Keys
```bash
# Option 1: Copy from backup/old machine
scp -r user@old-machine:~/.ssh ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*      # private keys
chmod 644 ~/.ssh/*.pub     # public keys

# Option 2: Generate new and add to GitHub/GitLab
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub  # Add to GitHub Settings > SSH Keys
```

### GPG Keys
```bash
# On OLD machine - export:
gpg --export --armor YOUR_KEY_ID > public.key
gpg --export-secret-keys --armor YOUR_KEY_ID > private.key
gpg --export-ownertrust > ownertrust.txt

# On NEW machine - import:
gpg --import public.key
gpg --import private.key
gpg --import-ownertrust < ownertrust.txt

# Verify:
gpg --list-keys
gpg --list-secret-keys
```

## 🔄 Updating the Backup

Run on your current system to update all backup files:

```bash
cd ~/dotfiles
./bootstrap/backup-system.sh
git add -A
git commit -m "backup: update system backup $(date +%Y-%m-%d)"
git push
```

## 🛠️ Manual Installation (Dotfiles Only)

If you only want the dotfiles without full system restore:

```bash
git clone https://github.com/talhacaglar/clar-dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 📦 Included Configurations

| Category | Tools |
|----------|-------|
| **Window Manager** | Hyprland |
| **Status Bar** | Waybar |
| **Editor** | Neovim |
| **Terminal** | Ghostty |
| **Shell** | Fish + Starship prompt |
| **Monitoring** | btop, fastfetch |
| **Notifications** | Mako |
| **Launcher** | Walker |
| **Theming** | GTK 3/4, custom fonts |
| **Multiplexer** | Tmux |
| **System** | systemd services, pacman, mkinitcpio, grub |

## 🔐 Security

This repo excludes sensitive files via `.gitignore`:
- SSH keys (`.ssh/`)
- GPG keys (`.gnupg/`)
- API tokens and credentials
- Browser data and caches
- Application data with stored credentials
- Shell history files
- `*.bak.*` backup files

## 📝 Requirements

- Git
- Bash (for install scripts)
- Target applications installed (handled by `install-packages.sh`)
- Arch-based distribution (pacman package manager)

## 🔐 Secrets

Some configuration files hold credentials and are deliberately excluded from
this repository:

| File | Why it is excluded | How to set it up |
|------|--------------------|------------------|
| `config/fish/fish_variables` | Fish writes exported universal variables (API keys) into this file verbatim | See `config/fish/fish_variables.example`, then `set -Ux NAME "value"` |

If you fork this repo, keep these exclusions in place. Before committing, it is
worth checking that nothing sensitive slipped in:

```bash
git diff --cached | grep -iE 'api[_-]?key|token|secret|password|SETUVAR --export'
```

## 📄 License

MIT License - Feel free to use and modify.

---

**Note**: This is a personal configuration repository. Some configs may be specific to my workflow and hardware (NVIDIA GPU, specific monitors, etc.). Review before using.