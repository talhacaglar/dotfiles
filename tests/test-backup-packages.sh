#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source "$repo_dir/bootstrap/backup-system.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
DOTFILES_DIR="$test_dir"
log_info() { :; }
log_success() { :; }
pacman() { :; }
npm() { printf '%s\n' '/usr/lib' '├── @scope/tool@1.2.3' '└── plain@4.5.6'; }
pip() { :; }
pip3() { :; }
cargo() { echo 'sample v1.0.0:'; }
flatpak() { :; }
backup_packages
expected=$(printf '%s\n' '@scope/tool' 'plain')
[[ "$(cat "$test_dir/pkglist-npm.txt")" == "$expected" ]]
echo 'npm backup: PASS (scoped and plain package names)'
