#!/usr/bin/env zsh
# Completion configuration

# Add custom completion directories to fpath (MUST be before compinit)
# Include brew's zsh-completions if available
if type brew &>/dev/null; then
    fpath=($(brew --prefix)/share/zsh-completions $fpath)
fi
fpath=(~/.zsh_completions $fpath)

# Generate completions from tools (before compinit)
if command -v mise &> /dev/null; then
    mise completion zsh > "$HOME/.zsh_completions/_mise"
fi

# Load completions
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

# Load completion module
zmodload zsh/complist
