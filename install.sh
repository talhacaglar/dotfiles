#!/usr/bin/env bash
# Dotfiles installation script
# This script creates symlinks from the dotfiles repository to the proper locations

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup of existing files
backup_file() {
    local file="$1"
    if [[ -e "$file" || -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
        log_info "Backed up $file to $BACKUP_DIR/"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        log_warning "Source does not exist: $source"
        return 1
    fi

    backup_file "$target"

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    log_success "Linked $target -> $source"
}

# Install home directory dotfiles
install_home_dotfiles() {
    log_info "Installing home directory dotfiles..."
    local home_src="$DOTFILES_DIR/home"

    if [[ ! -d "$home_src" ]]; then
        log_warning "Home dotfiles directory not found: $home_src"
        return
    fi

    for file in "$home_src"/*; do
        [[ -e "$file" ]] || continue
        local basename="$(basename "$file")"
        create_symlink "$file" "$HOME/$basename"
    done
}

# Install .config directory configs
install_config_dotfiles() {
    log_info "Installing .config directory configs..."
    local config_src="$DOTFILES_DIR/config"

    if [[ ! -d "$config_src" ]]; then
        log_warning "Config dotfiles directory not found: $config_src"
        return
    fi

    for item in "$config_src"/*; do
        [[ -e "$item" ]] || continue
        local basename="$(basename "$item")"
        create_symlink "$item" "$HOME/.config/$basename"
    done
}

# Main installation
main() {
    log_info "Starting dotfiles installation..."
    log_info "Dotfiles directory: $DOTFILES_DIR"

    # Check if we're in the right place
    if [[ ! -f "$DOTFILES_DIR/.gitignore" ]]; then
        log_error "This doesn't appear to be the dotfiles repository root"
        exit 1
    fi

    install_home_dotfiles
    install_config_dotfiles

    log_success "Dotfiles installation complete!"
    log_info "Backups stored in: $BACKUP_DIR"
    log_info "You may need to restart your shell or source your config files"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi