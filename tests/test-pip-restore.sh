#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
source "$repo_dir/bootstrap/install-packages.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

DOTFILES_DIR="$test_dir/repo"
HOME="$test_dir/home"
CALL_LOG="$test_dir/python-args"
export HOME CALL_LOG
mkdir -p "$DOTFILES_DIR" "$HOME"
printf 'example-package==1.2.3\n' > "$DOTFILES_DIR/pkglist-pip.txt"

python3() {
    [[ "$1 $2 $3" == "-m venv --system-site-packages" ]]
    local venv="$4"
    mkdir -p "$venv/bin"
    cat > "$venv/bin/python" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALL_LOG"
STUB
    chmod +x "$venv/bin/python"
}

install_pip_packages
[[ "$(cat "$CALL_LOG")" == "-m pip install -r $DOTFILES_DIR/pkglist-pip.txt" ]]
[[ -d "$HOME/.local/share/dotfiles-python" ]]
echo 'PEP 668-safe pip restore: PASS'
