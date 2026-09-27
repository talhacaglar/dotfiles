#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source "$repo_dir/bootstrap/backup-system.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
DOTFILES_DIR="$test_dir/backup"
HOME="$test_dir/source-home"
mkdir -p "$HOME/.config/hypr"
printf 'test rc' > "$HOME/.bashrc"
printf 'test config' > "$HOME/.config/hypr/config"
log_info() { :; }
log_success() { :; }
systemctl() { echo 'example.service enabled'; }
cp() {
    # Never read real system configuration in this regression test.
    if [[ "$1" == /etc/* || "${2:-}" == /etc/* ]]; then
        [[ -d "$DOTFILES_DIR/system" ]]
    else
        command cp "$@"
    fi
}
backup_services
[[ -s "$DOTFILES_DIR/services/system-enabled.txt" ]]
[[ -s "$DOTFILES_DIR/services/user-enabled.txt" ]]
backup_etc
[[ -d "$DOTFILES_DIR/system" ]]
backup_dotfiles
[[ "$(cat "$DOTFILES_DIR/home/.bashrc")" == 'test rc' ]]
[[ "$(cat "$DOTFILES_DIR/config/hypr/config")" == 'test config' ]]
echo 'fresh backup destination directories: PASS'
