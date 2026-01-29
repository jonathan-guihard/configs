#!/usr/bin/env zsh
# Completion configuration

# Load completions
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

# Load completion module
zmodload zsh/complist

# Add custom completion directories to fpath
fpath=(~/.zsh_completions $fpath)
