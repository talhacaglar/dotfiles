#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source "$repo_dir/install.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
DOTFILES_DIR="$test_dir"
mkdir -p "$test_dir/home"
touch "$test_dir/home/.bashrc" "$test_dir/home/.profile" "$test_dir/home/..extra" "$test_dir/home/visible"
log_info() { :; }
create_symlink() { basename "$1"; }
actual=$(install_home_dotfiles | sort)
expected=$(printf '%s\n' '..extra' '.bashrc' '.profile' 'visible' | sort)
[[ "$actual" == "$expected" ]]
rm -f "$test_dir/home/"* "$test_dir/home/".[!.]* "$test_dir/home/"..?*
[[ -z "$(install_home_dotfiles)" ]]
echo 'home dotfiles: PASS (hidden, visible, empty directory)'
