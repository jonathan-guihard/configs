#!/usr/bin/env zsh
# zoxide configuration (modern replacement for autojump)

# Initialize zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
