#!/usr/bin/env bash
# Setup Nerd Font for VS Code, Cursor

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source utilities
source "${SCRIPT_DIR}/lib/platform.sh"
source "${SCRIPT_DIR}/lib/logging.sh"

section "Editor Font Configuration"

# Check if ShureTechMono Nerd Font is installed
if ! ls ~/Library/Fonts/ShureTechMonoNerdFont* &>/dev/null; then
    warn "ShureTechMono Nerd Font not found. Installing..."
    brew install --cask font-shure-tech-mono-nerd-font
    success "ShureTechMono Nerd Font installed"
else
    success "ShureTechMono Nerd Font already installed"
fi

# Function to merge JSON settings
merge_settings() {
    local target_file="$1"
    local source_settings="$2"

    if [[ ! -f "$target_file" ]]; then
        echo '{}' > "$target_file"
    fi

    # Use jq to merge settings (install if needed)
    if ! command -v jq &>/dev/null; then
        warn "jq not found, installing..."
        brew install jq
    fi

    # Merge settings
    jq -s '.[0] * .[1]' "$target_file" <(echo "$source_settings") > "${target_file}.tmp"
    mv "${target_file}.tmp" "$target_file"
}

# Configure editor fonts
configure_editor() {
    local app_name="$1"
    local app_dir="$2"
    local settings_file="$app_dir/User/settings.json"

    if [[ -d "$app_dir" ]]; then
        info "Configuring $app_name..."
        mkdir -p "$(dirname "$settings_file")"

        FONT_SETTINGS=$(cat "${SCRIPT_DIR}/config/vscode/settings.json")
        merge_settings "$settings_file" "$FONT_SETTINGS"

        success "$app_name font configured"
    else
        info "$app_name not found, skipping"
    fi
}

# Configure VS Code and Cursor
configure_editor "VS Code" "$HOME/Library/Application Support/Code"
configure_editor "Cursor" "$HOME/Library/Application Support/Cursor"

section "Font Configuration Complete"
info "Next steps:"
echo "  • VS Code/Cursor: Reload window (Cmd+Shift+P → 'Reload Window')"
echo "  • iTerm2: Restart iTerm2, then go to Profiles → Profile → Text → Font"
echo "  • Or manually select 'ShureTechMono Nerd Font' in your editor/terminal preferences"
