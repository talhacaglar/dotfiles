#!/usr/bin/env bash
# Restore system configurations from backup
# Run after install-packages.sh on fresh system

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

# Check if running as root for system configs
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_warning "Some operations require root. Re-run with sudo for full restore."
        return 1
    fi
    return 0
}

# Backup original file before replacing
backup_original() {
    local file="$1"
    if [[ -f "$file" ]] && [[ ! -f "$file.dotfiles-backup" ]]; then
        cp "$file" "$file.dotfiles-backup"
        log_info "Backed up $file"
    fi
}

# Restore /etc configurations
restore_etc_configs() {
    log_info "Restoring /etc configurations..."
    
    if ! check_root; then
        log_warning "Skipping /etc configs (need root)"
        return
    fi
    
    local sys_dir="$DOTFILES_DIR/system"
    
    # pacman.conf
    if [[ -f "$sys_dir/pacman.conf" ]]; then
        backup_original "/etc/pacman.conf"
        cp "$sys_dir/pacman.conf" /etc/pacman.conf
        log_success "Restored /etc/pacman.conf"
    fi
    
    # mkinitcpio.conf
    if [[ -f "$sys_dir/mkinitcpio.conf" ]]; then
        backup_original "/etc/mkinitcpio.conf"
        cp "$sys_dir/mkinitcpio.conf" /etc/mkinitcpio.conf
        log_success "Restored /etc/mkinitcpio.conf"
        # Regenerate initramfs
        mkinitcpio -P
        log_success "Regenerated initramfs"
    fi
    
    # grub config
    if [[ -f "$sys_dir/grub" ]]; then
        backup_original "/etc/default/grub"
        cp "$sys_dir/grub" /etc/default/grub
        log_success "Restored /etc/default/grub"
        # Update grub
        grub-mkconfig -o /boot/grub/grub.cfg
        log_success "Updated grub config"
    fi
    
    # pacman.d mirrorlist
    if [[ -d "$sys_dir/pacman.d" ]]; then
        cp -r "$sys_dir/pacman.d/"* /etc/pacman.d/
        log_success "Restored pacman.d configs"
    fi
    
    # modprobe.d
    if [[ -d "$sys_dir/modprobe.d" ]]; then
        cp -r "$sys_dir/modprobe.d/"* /etc/modprobe.d/
        log_success "Restored modprobe.d rules"
    fi
    
    # sysctl.d
    if [[ -d "$sys_dir/sysctl.d" ]]; then
        cp -r "$sys_dir/sysctl.d/"* /etc/sysctl.d/
        sysctl --system
        log_success "Restored sysctl.d configs"
    fi
    
    # udev rules
    if [[ -d "$sys_dir/rules.d" ]]; then
        cp -r "$sys_dir/rules.d/"* /etc/udev/rules.d/
        udevadm control --reload-rules
        udevadm trigger
        log_success "Restored udev rules"
    fi
}

# Enable systemd services
enable_services() {
    log_info "Enabling systemd services..."
    
    local services_file="$DOTFILES_DIR/services/system-enabled.txt"
    if [[ ! -f "$services_file" ]]; then
        log_warning "Services file not found"
        return
    fi
    
    if ! check_root; then
        log_warning "Skipping system services (need root)"
    else
        while IFS= read -r line; do
            local service=$(echo "$line" | awk '{print $1}')
            [[ -z "$service" ]] && continue
            if systemctl list-unit-files "$service" &>/dev/null; then
                systemctl enable "$service" 2>/dev/null && log_info "Enabled $service" || log_warning "Failed to enable $service"
            fi
        done < "$services_file"
        log_success "System services processed"
    fi
    
    # User services (run as user, not root)
    local user_services="$DOTFILES_DIR/services/user-enabled.txt"
    if [[ -f "$user_services" ]]; then
        log_info "Enabling user services..."
        while IFS= read -r line; do
            local service=$(echo "$line" | awk '{print $1}')
            [[ -z "$service" ]] && continue
            if systemctl --user list-unit-files "$service" &>/dev/null; then
                systemctl --user enable "$service" 2>/dev/null && log_info "Enabled user $service" || log_warning "Failed to enable user $service"
            fi
        done < "$user_services"
        log_success "User services processed"
    fi
}

# Restore fonts, themes, icons
restore_fonts_themes() {
    log_info "Restoring fonts, themes, icons..."
    
    local fonts_dir="$DOTFILES_DIR/fonts"
    
    # Fonts
    if [[ -d "$fonts_dir/fonts" ]] && [[ -n "$(ls -A "$fonts_dir/fonts")" ]]; then
        mkdir -p ~/.local/share/fonts
        cp -r "$fonts_dir/fonts/"* ~/.local/share/fonts/
        fc-cache -fv
        log_success "Fonts restored"
    fi
    
    # Themes
    if [[ -d "$fonts_dir/themes" ]] && [[ -n "$(ls -A "$fonts_dir/themes")" ]]; then
        mkdir -p ~/.local/share/themes
        cp -r "$fonts_dir/themes/"* ~/.local/share/themes/
        log_success "Themes restored"
    fi
    
    # Icons
    if [[ -d "$fonts_dir/icons" ]] && [[ -n "$(ls -A "$fonts_dir/icons")" ]]; then
        mkdir -p ~/.local/share/icons
        cp -r "$fonts_dir/icons/"* ~/.local/share/icons/
        gtk-update-icon-cache ~/.local/share/icons/*/ 2>/dev/null || true
        log_success "Icons restored"
    fi
}

# Print SSH/GPG key import instructions
print_key_instructions() {
    cat << 'EOF'

========================================
SSH / GPG KEY IMPORT INSTRUCTIONS
========================================

Keys are NOT stored in this repository for security.
You must manually import them from your backup.

SSH Keys:
---------
1. Copy your ~/.ssh/ directory from backup to new system:
   scp -r user@old-machine:~/.ssh ~/.ssh
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_* (private keys)
   chmod 644 ~/.ssh/*.pub (public keys)

2. Or generate new keys and add to GitHub/GitLab:
   ssh-keygen -t ed25519 -C "your@email.com"
   cat ~/.ssh/id_ed25519.pub  # Add to GitHub

GPG Keys:
---------
1. Export from old system:
   gpg --export --armor YOUR_KEY_ID > public.key
   gpg --export-secret-keys --armor YOUR_KEY_ID > private.key
   gpg --export-ownertrust > ownertrust.txt

2. Import on new system:
   gpg --import public.key
   gpg --import private.key
   gpg --import-ownertrust < ownertrust.txt

3. Verify:
   gpg --list-keys
   gpg --list-secret-keys

========================================

EOF
}

# Main
main() {
    log_info "Starting system configuration restore..."
    log_info "Dotfiles directory: $DOTFILES_DIR"
    
    restore_etc_configs
    enable_services
    restore_fonts_themes
    print_key_instructions
    
    log_success "System restore complete!"
    log_info "Next steps:"
    log_info "  1. Run ./install.sh to symlink dotfiles"
    log_info "  2. Import SSH/GPG keys (see instructions above)"
    log_info "  3. Reboot"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi