#!/usr/bin/env zsh
# direnv configuration

# Initialize direnv if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi
