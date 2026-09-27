#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source "$repo_dir/bootstrap/backup-system.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
DOTFILES_DIR="$test_dir"
log_info() { :; }
log_success() { :; }
pacman() {
    case "$1" in
        -Qen) echo 'native 1.0';;
        -Qm) echo 'foreign 2.0';;
        -Qe) printf '%s\n' 'native 1.0' 'foreign 2.0';;
        *) return 1;;
    esac
}
npm() { printf '%s\n' '/usr/lib' '├── @scope/tool@1.2.3' '└── plain@4.5.6'; }
pip() { :; }
pip3() { :; }
cargo() { echo 'sample v1.0.0:'; }
flatpak() { :; }
backup_packages
expected=$(printf '%s\n' '@scope/tool' 'plain')
[[ "$(cat "$test_dir/pkglist-npm.txt")" == "$expected" ]]
[[ "$(cat "$test_dir/pkglist-pacman.txt")" == 'native 1.0' ]]
[[ "$(cat "$test_dir/pkglist-aur.txt")" == 'foreign 2.0' ]]
echo 'package backup: PASS (scoped npm names and native/foreign separation)' 
