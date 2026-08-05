source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# ==========================================
# Omarchy Configurations
# ==========================================
set -gx OMARCHY_PATH "$HOME/.local/share/omarchy"
fish_add_path "$OMARCHY_PATH/bin"

# Quick Shortcuts & Aliases
alias n="nvim"
alias t="tmux"
alias ls="eza"
alias lsa="eza -a"
alias lt="eza --tree --level=2"
alias lta="eza --tree --level=2 -a"
alias ff="fzf"
alias gg="lazygit"
alias ld="lazydocker"

# Initialize Mise
if type -q mise
    mise activate fish | source
end

# Initialize Zoxide
if type -q zoxide
    zoxide init fish | source
end

fish_add_path /home/clar/.spicetify
