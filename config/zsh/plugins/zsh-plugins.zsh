#!/usr/bin/env zsh
# Zsh plugin loading (autosuggestions, syntax-highlighting)

# Detect platform
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# Load plugins based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS with Homebrew
    BREW_PREFIX="$(brew --prefix 2>/dev/null)"

    if [[ -n "$BREW_PREFIX" ]]; then
        source_if_exists "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        source_if_exists "${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - try common package manager locations

    # Ubuntu/Debian
    source_if_exists "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    source_if_exists "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # Fedora/RHEL
    source_if_exists "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    source_if_exists "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

    # Arch
    source_if_exists "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    source_if_exists "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
