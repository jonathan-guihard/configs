#!/usr/bin/env zsh
# Shell aliases

# Editor
alias vim="nvim"
alias vi="nvim"

# Config editing
alias zshrc="vim ~/.zshrc"

# Useful Oh My Zsh git aliases (without requiring OMZ)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gcam='git commit -a -m'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias gcm='git checkout main'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gpl='git pull --rebase'
alias gl='git log --oneline --decorate --graph'
alias gll='git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all'
alias gm='git merge'
alias gp='git push'
alias gst='git status'
alias gsta='git stash'
alias gstp='git stash pop'

# Modern CLI tools
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

if command -v fd &> /dev/null; then
    alias find='fd'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# ls with colors
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -G'
else
    alias ls='ls --color=auto'
fi
alias ll='ls -lh'
alias la='ls -lAh'
