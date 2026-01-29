#!/usr/bin/env bash
# Platform detection utilities

detect_platform() {
    case "$OSTYPE" in
        darwin*) echo "macos" ;;
        linux*) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Get brew prefix (handles both Intel and Apple Silicon)
get_brew_prefix() {
    if is_macos; then
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            echo "/opt/homebrew"
        elif [[ -x "/usr/local/bin/brew" ]]; then
            echo "/usr/local"
        else
            echo ""
        fi
    else
        echo ""
    fi
}
