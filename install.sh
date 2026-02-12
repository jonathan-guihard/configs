#!/usr/bin/env bash
# Interactive installation script for dotfiles

set -e

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Source utilities
source "${DOTFILES_DIR}/lib/platform.sh"
source "${DOTFILES_DIR}/lib/logging.sh"
source "${DOTFILES_DIR}/lib/symlink.sh"

# Welcome
section "Dotfiles Installation"
info "This script will set up your dotfiles configuration."
info "It will:"
echo "  • Create symlinks for configuration files"
echo "  • Generate config files from templates"
echo "  • Set up functions and completions"
echo "  • Configure zsh as your default shell"
echo ""
warn "Existing files will be backed up with a timestamp."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Installation cancelled."
    exit 0
fi

# Interactive prompts
section "Configuration"

# Git user configuration
read -p "Git user email: " GIT_USER_EMAIL

# Private/enterprise config prompts
HAS_PRIVATE_CONFIG=false
if [[ -d "$DOTFILES_DIR/private" ]]; then
    echo ""
    info "Private configuration detected"
    read -p "Configure enterprise settings? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        HAS_PRIVATE_CONFIG=true
        read -p "SSH username for work hosts: " SSH_USER
        read -p "SSH identity file for work hosts: " SSH_IDENTITY_FILE

        USE_1PASSWORD=false
        if is_macos; then
            read -p "Use 1Password SSH agent? (y/n) " -n 1 -r
            echo
            [[ $REPLY =~ ^[Yy]$ ]] && USE_1PASSWORD=true
        fi
    fi
fi

# Create necessary directories
section "Creating Directories"
create_dir_if_missing "$HOME/.config"
create_dir_if_missing "$HOME/.config/zsh"
create_dir_if_missing "$HOME/.zsh_functions"
create_dir_if_missing "$HOME/.zsh_completions"

# Generate gitconfig from template
section "Generating Git Configuration"
info "Creating ~/.gitconfig from template..."

GITCONFIG_CONTENT=$(cat "${DOTFILES_DIR}/config/git/gitconfig.template")
GITCONFIG_CONTENT="${GITCONFIG_CONTENT//\{\{GIT_USER_EMAIL\}\}/$GIT_USER_EMAIL}"

# Backup existing gitconfig
if [[ -f "$HOME/.gitconfig" ]]; then
    backup="$HOME/.gitconfig.backup.$(date +%Y%m%d_%H%M%S)"
    warn "Backing up existing .gitconfig to $backup"
    mv "$HOME/.gitconfig" "$backup"
fi

echo "$GITCONFIG_CONTENT" > "$HOME/.gitconfig"
success "Created ~/.gitconfig"

# Create global gitignore symlink
create_symlink "${DOTFILES_DIR}/config/git/gitignore_global" "$HOME/.gitignore_global"

# Create git template directory symlink
create_symlink "${DOTFILES_DIR}/config/git/git-template" "$HOME/.git-template"

# Generate SSH config from template if private config exists
if [[ $HAS_PRIVATE_CONFIG == true ]]; then
    section "Generating SSH Configuration"

    SSH_CONFIG_CONTENT=$(cat "${DOTFILES_DIR}/private/config/ssh/config.template")
    SSH_CONFIG_CONTENT="${SSH_CONFIG_CONTENT//\{\{SSH_USER\}\}/$SSH_USER}"
    SSH_CONFIG_CONTENT="${SSH_CONFIG_CONTENT//\{\{SSH_IDENTITY_FILE\}\}/$SSH_IDENTITY_FILE}"

    if is_macos && [[ $USE_1PASSWORD == true ]]; then
        SSH_CONFIG_CONTENT="${SSH_CONFIG_CONTENT//\{\{1PASSWORD_AGENT_PATH\}\}/$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock}"
    else
        # Remove the 1Password line if not using it
        SSH_CONFIG_CONTENT=$(echo "$SSH_CONFIG_CONTENT" | grep -v "{{1PASSWORD_AGENT_PATH}}")
    fi

    if [[ -f "$HOME/.ssh/config" ]]; then
        backup="$HOME/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing .ssh/config to $backup"
        mv "$HOME/.ssh/config" "$backup"
    fi

    mkdir -p "$HOME/.ssh"
    echo "$SSH_CONFIG_CONTENT" > "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
    success "Created ~/.ssh/config"
fi

# Create UV config
section "UV Configuration"
if [[ $HAS_PRIVATE_CONFIG == true ]] && [[ -f "${DOTFILES_DIR}/private/config/uv/uv.toml" ]]; then
    create_symlink "${DOTFILES_DIR}/private/config/uv/uv.toml" "$HOME/.config/uv/uv.toml"
else
    # Copy public template
    create_dir_if_missing "$HOME/.config/uv"
    cp "${DOTFILES_DIR}/config/uv/uv.toml.template" "$HOME/.config/uv/uv.toml"
    success "Created ~/.config/uv/uv.toml from template"
fi

# Create symlinks for config files
section "Creating Configuration Symlinks"

# Zsh
create_symlink "${DOTFILES_DIR}/config/zsh/zshrc" "$HOME/.zshrc"

# Starship
create_symlink "${DOTFILES_DIR}/config/starship/starship.toml" "$HOME/.config/starship.toml"

# Vim
create_symlink "${DOTFILES_DIR}/config/nvim/init.vim" "$HOME/.config/nvim/init.vim"

# Ghostty
create_symlink "${DOTFILES_DIR}/config/ghostty/config" "$HOME/.config/ghostty/config"

# Link public functions
section "Setting Up Functions"
for func in "${DOTFILES_DIR}/functions"/*; do
    if [[ -f "$func" ]]; then
        func_name=$(basename "$func")
        create_symlink "$func" "$HOME/.zsh_functions/$func_name"
    fi
done

# Link private functions if available
if [[ $HAS_PRIVATE_CONFIG == true ]] && [[ -d "${DOTFILES_DIR}/private/functions" ]]; then
    for func in "${DOTFILES_DIR}/private/functions"/*; do
        if [[ -f "$func" ]]; then
            func_name=$(basename "$func")
            create_symlink "$func" "$HOME/.zsh_functions/$func_name"
        fi
    done
fi

# Link public completions
section "Setting Up Completions"
if [[ -d "${DOTFILES_DIR}/completions" ]]; then
    for comp in "${DOTFILES_DIR}/completions"/*; do
        if [[ -f "$comp" ]]; then
            comp_name=$(basename "$comp")
            create_symlink "$comp" "$HOME/.zsh_completions/$comp_name"
        fi
    done
fi

# Link private completions if available
if [[ $HAS_PRIVATE_CONFIG == true ]] && [[ -d "${DOTFILES_DIR}/private/completions" ]]; then
    for comp in "${DOTFILES_DIR}/private/completions"/*; do
        if [[ -f "$comp" ]]; then
            comp_name=$(basename "$comp")
            create_symlink "$comp" "$HOME/.zsh_completions/$comp_name"
        fi
    done
fi

# Set zsh as default shell
section "Default Shell"
if [[ "$SHELL" != *"zsh"* ]]; then
    info "Current shell: $SHELL"
    read -p "Set zsh as your default shell? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ZSH_PATH=$(which zsh)

        # Add zsh to /etc/shells if not already there
        if ! grep -q "$ZSH_PATH" /etc/shells; then
            info "Adding $ZSH_PATH to /etc/shells..."
            echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
        fi

        info "Changing default shell to zsh..."
        chsh -s "$ZSH_PATH"
        success "Default shell set to zsh"
    else
        info "Skipping shell change"
    fi
else
    success "zsh is already your default shell"
fi

# Setup editor fonts
section "Editor Font Configuration"
info "Configuring Nerd Fonts for editors and terminals..."
if [[ -f "${DOTFILES_DIR}/scripts/setup-editor-fonts.sh" ]]; then
    "${DOTFILES_DIR}/scripts/setup-editor-fonts.sh"
else
    warn "Font setup script not found, skipping"
fi

# Verification
section "Verification"
info "Checking installation..."

# Check symlinks
check_symlink() {
    local target="$1"
    if [[ -L "$target" ]]; then
        success "✓ $target"
    else
        warn "✗ $target (not a symlink)"
    fi
}

check_symlink "$HOME/.zshrc"
check_symlink "$HOME/.config/starship.toml"
check_symlink "$HOME/.config/nvim/init.vim"
check_symlink "$HOME/.config/ghostty/config"
check_symlink "$HOME/.gitignore_global"

# Summary
section "Installation Complete! 🎉"
echo ""
success "Your dotfiles have been installed successfully!"
echo ""
info "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo ""
info "Configuration files:"
echo "  • Zsh: ~/.zshrc -> ${DOTFILES_DIR}/config/zsh/zshrc"
echo "  • Git: ~/.gitconfig"
echo "  • Starship: ~/.config/starship.toml"
echo "  • Neovim: ~/.config/nvim/init.vim"
echo "  • Ghostty: ~/.config/ghostty/config"
echo ""
info "To customize further:"
echo "  • Machine-specific settings: ${DOTFILES_DIR}/local/*.zsh"
echo "  • Edit configs in: ${DOTFILES_DIR}"
echo ""
