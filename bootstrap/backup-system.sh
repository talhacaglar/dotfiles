#!/usr/bin/env bash
# Backup current system state to dotfiles repository
# Run periodically to keep backup up to date

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Backup package lists
backup_packages() {
    log_info "Backing up package lists..."
    
    pacman -Qen > "$DOTFILES_DIR/pkglist-pacman.txt"
    log_success "Pacman packages: $(wc -l < "$DOTFILES_DIR/pkglist-pacman.txt")"
    
    pacman -Qm > "$DOTFILES_DIR/pkglist-aur.txt"
    log_success "AUR packages: $(wc -l < "$DOTFILES_DIR/pkglist-aur.txt")"
    
    if command -v npm &>/dev/null; then
        npm list -g --depth=0 2>/dev/null | tail -n +2 | sed 's/[├└─]//g' | sed 's/──//g' | awk '{print $1}' | sed 's/@[^@]*$//' > "$DOTFILES_DIR/pkglist-npm.txt"
        log_success "npm packages: $(wc -l < "$DOTFILES_DIR/pkglist-npm.txt")"
    fi
    
    if command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
        pip list --format=freeze > "$DOTFILES_DIR/pkglist-pip.txt" 2>/dev/null || pip3 list --format=freeze > "$DOTFILES_DIR/pkglist-pip.txt"
        log_success "pip packages: $(wc -l < "$DOTFILES_DIR/pkglist-pip.txt")"
    fi
    
    if command -v cargo &>/dev/null; then
        cargo install --list 2>/dev/null | awk '/^[a-z0-9_-]+ v[0-9]/ {print $1}' > "$DOTFILES_DIR/pkglist-cargo.txt"
        log_success "cargo packages: $(wc -l < "$DOTFILES_DIR/pkglist-cargo.txt")"
    fi
    
    if command -v flatpak &>/dev/null; then
        flatpak list --app --columns=application > "$DOTFILES_DIR/pkglist-flatpak.txt" 2>/dev/null
        log_success "flatpak packages: $(wc -l < "$DOTFILES_DIR/pkglist-flatpak.txt")"
    fi
}

# Backup systemd services
backup_services() {
    log_info "Backing up systemd services..."
    
    systemctl list-unit-files --state=enabled --no-legend > "$DOTFILES_DIR/services/system-enabled.txt" 2>/dev/null
    systemctl --user list-unit-files --state=enabled --no-legend > "$DOTFILES_DIR/services/user-enabled.txt" 2>/dev/null
    systemctl list-timers --all --no-legend > "$DOTFILES_DIR/services/timers.txt" 2>/dev/null
    
    log_success "Services backed up"
}

# Backup /etc configs
backup_etc() {
    log_info "Backing up /etc configurations..."
    
    cp /etc/pacman.conf "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp /etc/mkinitcpio.conf "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp /etc/default/grub "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp -r /etc/pacman.d/ "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp -r /etc/modprobe.d/ "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp -r /etc/sysctl.d/ "$DOTFILES_DIR/system/" 2>/dev/null || true
    cp -r /etc/udev/rules.d/ "$DOTFILES_DIR/system/" 2>/dev/null || true
    
    log_success "/etc configs backed up"
}

# Backup fonts, themes, icons
backup_fonts() {
    log_info "Backing up fonts, themes, icons..."
    
    mkdir -p "$DOTFILES_DIR/fonts/fonts"
    mkdir -p "$DOTFILES_DIR/fonts/themes"
    mkdir -p "$DOTFILES_DIR/fonts/icons"
    
    cp -r ~/.local/share/fonts/* "$DOTFILES_DIR/fonts/fonts/" 2>/dev/null || true
    cp -r ~/.fonts/* "$DOTFILES_DIR/fonts/fonts/" 2>/dev/null || true
    cp -r ~/.local/share/themes/* "$DOTFILES_DIR/fonts/themes/" 2>/dev/null || true
    cp -r ~/.themes/* "$DOTFILES_DIR/fonts/themes/" 2>/dev/null || true
    cp -r ~/.local/share/icons/* "$DOTFILES_DIR/fonts/icons/" 2>/dev/null || true
    cp -r ~/.icons/* "$DOTFILES_DIR/fonts/icons/" 2>/dev/null || true
    
    log_success "Fonts/themes/icons backed up"
}

# Backup dotfiles (home and .config)
backup_dotfiles() {
    log_info "Backing up dotfiles..."
    
    # Home dotfiles
    cp ~/.bashrc ~/.bash_profile ~/.bash_logout ~/.zshrc ~/.profile ~/.XCompose ~/.gtkrc-2.0 "$DOTFILES_DIR/home/" 2>/dev/null || true
    
    # Config directories
    local config_dirs=("hypr" "waybar" "nvim" "ghostty" "fish" "btop" "fastfetch" "mako" "walker" "gtk-3.0" "gtk-4.0" "tmux" "mimeapps.list" "environment.d" "fontconfig" "starship.toml")
    
    for item in "${config_dirs[@]}"; do
        if [[ -e ~/.config/"$item" ]]; then
            cp -r ~/.config/"$item" "$DOTFILES_DIR/config/" 2>/dev/null || true
        fi
    done
    
    log_success "Dotfiles backed up"
}

# Main
main() {
    log_info "Starting system backup to dotfiles..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    backup_packages
    backup_services
    backup_etc
    backup_fonts
    backup_dotfiles
    
    log_success "Backup complete!"
    log_info "Run 'cd $DOTFILES_DIR && git add -A && git commit -m \"backup: update system backup\" && git push' to save"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi