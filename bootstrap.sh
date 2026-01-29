#!/usr/bin/env bash
# Bootstrap script - Initial setup and dependency installation

set -e

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
success() { echo -e "${GREEN}✅ $*${NC}"; }
error() { echo -e "${RED}❌ $*${NC}" >&2; }
warn() { echo -e "${YELLOW}⚠️  $*${NC}"; }

section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$*${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Platform detection
detect_platform() {
    case "$OSTYPE" in
        darwin*) echo "macos" ;;
        linux*) echo "linux" ;;
        *) echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)

section "Dotfiles Bootstrap"
info "Platform: $PLATFORM"
info "Dotfiles directory: $DOTFILES_DIR"

# Check for required tools
section "Checking Prerequisites"

if ! command -v git &> /dev/null; then
    error "git is not installed. Please install git first."
    exit 1
fi
success "git is installed"

if ! command -v curl &> /dev/null; then
    error "curl is not installed. Please install curl first."
    exit 1
fi
success "curl is installed"

# Install Homebrew on macOS
if [[ "$PLATFORM" == "macos" ]]; then
    section "Homebrew Setup"

    if command -v brew &> /dev/null; then
        success "Homebrew is already installed"
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        success "Homebrew installed successfully"
    fi
fi

# Initialize git submodule if it exists
if [[ -f "$DOTFILES_DIR/.gitmodules" ]]; then
    section "Initializing Git Submodules"
    info "Updating submodule (private configs)..."
    cd "$DOTFILES_DIR"
    git submodule update --init --recursive
    success "Submodule initialized"
fi

# Install dependencies
section "Installing Dependencies"

if [[ "$PLATFORM" == "macos" ]]; then
    # Install public packages
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        info "Installing packages from Brewfile..."
        cd "$DOTFILES_DIR"
        brew bundle
        success "Public packages installed"
    fi

    # Install private/enterprise packages
    if [[ -d "$DOTFILES_DIR/private" ]] && [[ -f "$DOTFILES_DIR/private/Brewfile" ]]; then
        echo ""
        info "Private configuration detected"
        read -p "Install enterprise packages from private Brewfile? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            info "Installing packages from private Brewfile..."
            cd "$DOTFILES_DIR/private"
            brew bundle
            success "Enterprise packages installed"
            cd "$DOTFILES_DIR"
        else
            info "Skipping enterprise packages"
        fi
    fi
elif [[ "$PLATFORM" == "linux" ]]; then
    info "Installing Linux dependencies..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y zsh neovim fzf direnv ripgrep fd-find bat tree jq wget htop tmux
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zsh neovim fzf direnv ripgrep fd-find bat tree jq wget htop tmux
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zsh neovim fzf direnv ripgrep fd bat tree jq wget htop tmux
    else
        warn "Unknown package manager. Please install dependencies manually."
    fi

    # Install starship
    if ! command -v starship &> /dev/null; then
        info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Install zoxide
    if ! command -v zoxide &> /dev/null; then
        info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # Install UV
    if ! command -v uv &> /dev/null; then
        info "Installing UV..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
fi

success "Bootstrap complete!"
echo ""
info "Next steps:"
echo "  1. Run: cd $DOTFILES_DIR"
echo "  2. Run: ./install.sh"
echo ""
