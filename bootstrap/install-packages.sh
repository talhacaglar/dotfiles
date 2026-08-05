#!/usr/bin/env bash
# Install all packages from backup lists
# Run on fresh Arch-based system after base install

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "Don't run this script as root!"
    exit 1
fi

# Install AUR helper (yay)
install_aur_helper() {
    if command -v yay &>/dev/null; then
        log_info "yay already installed"
        return
    fi
    
    log_info "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/yay
    log_success "yay installed"
}

# Install pacman packages
install_pacman_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-pacman.txt"
    if [[ ! -f "$pkglist" ]]; then
        log_warning "Pacman package list not found: $pkglist"
        return
    fi
    
    log_info "Installing pacman packages..."
    # Filter out base packages that are already installed
    local to_install=()
    while IFS= read -r line; do
        local pkg="${line%% *}"
        if ! pacman -Q "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done < "$pkglist"
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing ${#to_install[@]} packages..."
        sudo pacman -S --needed --noconfirm "${to_install[@]}"
        log_success "Pacman packages installed"
    else
        log_info "All pacman packages already installed"
    fi
}

# Install AUR packages
install_aur_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-aur.txt"
    if [[ ! -f "$pkglist" ]]; then
        log_warning "AUR package list not found: $pkglist"
        return
    fi
    
    if ! command -v yay &>/dev/null; then
        log_error "yay not installed, skipping AUR packages"
        return
    fi
    
    log_info "Installing AUR packages..."
    local to_install=()
    while IFS= read -r line; do
        local pkg="${line%% *}"
        if ! pacman -Q "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done < "$pkglist"
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing ${#to_install[@]} AUR packages..."
        yay -S --needed --noconfirm "${to_install[@]}"
        log_success "AUR packages installed"
    else
        log_info "All AUR packages already installed"
    fi
}

# Install npm packages
install_npm_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-npm.txt"
    if [[ ! -f "$pkglist" ]] || [[ ! -s "$pkglist" ]]; then
        log_info "No npm packages to install"
        return
    fi
    
    if ! command -v npm &>/dev/null; then
        log_warning "npm not installed, skipping npm packages"
        return
    fi
    
    log_info "Installing npm global packages..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if ! npm list -g "$pkg" &>/dev/null; then
            npm install -g "$pkg"
        fi
    done < "$pkglist"
    log_success "npm packages installed"
}

# Install pip packages
install_pip_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-pip.txt"
    if [[ ! -f "$pkglist" ]] || [[ ! -s "$pkglist" ]]; then
        log_info "No pip packages to install"
        return
    fi
    
    if ! command -v pip &>/dev/null && ! command -v pip3 &>/dev/null; then
        log_warning "pip not installed, skipping pip packages"
        return
    fi
    
    log_info "Installing pip packages..."
    pip install --user -r "$pkglist" 2>/dev/null || pip3 install --user -r "$pkglist"
    log_success "pip packages installed"
}

# Install cargo packages
install_cargo_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-cargo.txt"
    if [[ ! -f "$pkglist" ]] || [[ ! -s "$pkglist" ]]; then
        log_info "No cargo packages to install"
        return
    fi
    
    if ! command -v cargo &>/dev/null; then
        log_warning "cargo not installed, skipping cargo packages"
        return
    fi
    
    log_info "Installing cargo packages..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if ! cargo install --list | grep -q "^$pkg "; then
            cargo install "$pkg"
        fi
    done < "$pkglist"
    log_success "cargo packages installed"
}

# Install flatpak packages
install_flatpak_packages() {
    local pkglist="$DOTFILES_DIR/pkglist-flatpak.txt"
    if [[ ! -f "$pkglist" ]] || [[ ! -s "$pkglist" ]]; then
        log_info "No flatpak packages to install"
        return
    fi
    
    if ! command -v flatpak &>/dev/null; then
        log_warning "flatpak not installed, skipping flatpak packages"
        return
    fi
    
    log_info "Installing flatpak packages..."
    while IFS= read -r app; do
        [[ -z "$app" ]] && continue
        flatpak install -y flathub "$app"
    done < "$pkglist"
    log_success "flatpak packages installed"
}

# Main
main() {
    log_info "Starting package installation from dotfiles backup..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    install_aur_helper
    install_pacman_packages
    install_aur_packages
    install_npm_packages
    install_pip_packages
    install_cargo_packages
    install_flatpak_packages
    
    log_success "All packages installed!"
    log_info "Next steps:"
    log_info "  1. Run ./bootstrap/restore-system.sh to apply system configs"
    log_info "  2. Run ./install.sh to symlink dotfiles"
    log_info "  3. Reboot"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi