#!/usr/bin/env bash
# Uninstall script for dotfiles

set -e

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Source utilities
source "${DOTFILES_DIR}/lib/logging.sh"

# Welcome
section "Dotfiles Uninstallation"
warn "This will remove all dotfiles symlinks and configurations."
echo ""
read -p "Continue with uninstallation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Uninstallation cancelled."
    exit 0
fi

# Remove symlinks
section "Removing Symlinks"

remove_if_symlink() {
    local target="$1"
    if [[ -L "$target" ]]; then
        rm "$target"
        success "Removed: $target"
    elif [[ -e "$target" ]]; then
        warn "Not a symlink (skipping): $target"
    else
        info "Not found (skipping): $target"
    fi
}

# Zsh
remove_if_symlink "$HOME/.zshrc"

# Starship
remove_if_symlink "$HOME/.config/starship.toml"

# Neovim
remove_if_symlink "$HOME/.config/nvim/init.vim"

# Git
remove_if_symlink "$HOME/.gitignore_global"
remove_if_symlink "$HOME/.git-template"

# Functions
if [[ -d "$HOME/.zsh_functions" ]]; then
    info "Checking functions directory..."
    # Only remove symlinks, not the directory itself
    find "$HOME/.zsh_functions" -type l -exec rm {} \;
    success "Removed function symlinks"
fi

# Completions
if [[ -d "$HOME/.zsh_completions" ]]; then
    info "Checking completions directory..."
    # Only remove symlinks, not the directory itself
    find "$HOME/.zsh_completions" -type l -exec rm {} \;
    success "Removed completion symlinks"
fi

# Show backups
section "Available Backups"
BACKUPS=$(ls -d "$HOME"/*.backup.* 2>/dev/null || true)
if [[ -n "$BACKUPS" ]]; then
    echo "$BACKUPS"
    echo ""
    read -p "Restore backups? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Please restore backups manually by reviewing and copying files."
        info "Example: cp ~/.zshrc.backup.20260129_123456 ~/.zshrc"
    fi
else
    info "No backup files found"
fi

# Optional: Remove gitconfig
section "Git Configuration"
if [[ -f "$HOME/.gitconfig" ]]; then
    warn "Found ~/.gitconfig (generated from template)"
    read -p "Remove ~/.gitconfig? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$HOME/.gitconfig"
        success "Removed ~/.gitconfig"
    else
        info "Keeping ~/.gitconfig"
    fi
fi

# Optional: Remove SSH config
section "SSH Configuration"
if [[ -f "$HOME/.ssh/config" ]]; then
    warn "Found ~/.ssh/config (may contain enterprise settings)"
    read -p "Remove ~/.ssh/config? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        backup="$HOME/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$HOME/.ssh/config" "$backup"
        success "Backed up to: $backup"
    else
        info "Keeping ~/.ssh/config"
    fi
fi

# Optional: Remove UV config
section "UV Configuration"
if [[ -f "$HOME/.config/uv/uv.toml" ]]; then
    read -p "Remove UV configuration? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm "$HOME/.config/uv/uv.toml"
        success "Removed ~/.config/uv/uv.toml"
    else
        info "Keeping ~/.config/uv/uv.toml"
    fi
fi

# Optional: Remove repository
section "Repository"
warn "The dotfiles repository is at: $DOTFILES_DIR"
read -p "Remove the entire repository? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Are you SURE? This cannot be undone! (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$HOME"
        rm -rf "$DOTFILES_DIR"
        success "Repository removed"
        echo ""
        info "Uninstallation complete!"
        exit 0
    fi
fi

# Summary
section "Uninstallation Complete!"
echo ""
success "Symlinks and configurations have been removed."
echo ""
info "Next steps:"
echo "  • Restart your terminal"
echo "  • The repository is still at: $DOTFILES_DIR"
echo "  • To remove it: rm -rf $DOTFILES_DIR"
echo "  • Backup files are preserved in your home directory"
echo ""
