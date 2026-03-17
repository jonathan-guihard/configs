#!/usr/bin/env zsh
# direnv configuration

# Only initialize direnv if available and mise is not active
# (mise replaces direnv for env/tool management)
if command -v direnv &> /dev/null && ! command -v mise &> /dev/null; then
    eval "$(direnv hook zsh)"
fi
