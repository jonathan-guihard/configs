#!/usr/bin/env zsh
# FZF configuration

# Source FZF if available
if command -v fzf &> /dev/null; then
    # Use fzf's built-in zsh integration
    if [[ -f ~/.fzf.zsh ]]; then
        source ~/.fzf.zsh
    elif command -v fzf-share &> /dev/null; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
    else
        # Try to source from common locations
        source <(fzf --zsh) 2>/dev/null
    fi

    # FZF options
    export FZF_DEFAULT_OPTS='--history-size=100000'
    export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

    # Use fd for file listing if available
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi
