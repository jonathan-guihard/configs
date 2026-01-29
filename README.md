# Dotfiles Configuration

A modular, cross-platform dotfiles repository using Starship with submodule for enterprise configurations.

## Features

- 🚀 **Starship prompt** - Fast, customizable, cross-shell prompt
- 🔧 **Modular zsh configuration** - Easy to understand and maintain
- 🌍 **Cross-platform** - Works on macOS and Linux
- 🔒 **Git conditional includes** - Auto-switch between personal/work configs
- 🐍 **UV Python manager** - Modern, fast Python package management
- 🔐 **Private Submodule** - Separate enterprise-specific configurations
- ⚡ **Modern CLI tools** - bat, fd, ripgrep, zoxide, and more

## Quick Start

```bash
# Clone the repository
git clone git@github.com:jonathan-guihard/configs.git ~/configs
cd ~/configs

# Add private submodule (optional, for enterprise configs)
git submodule add git@github.com:jonathan-guihard/nexthink-config.git private

# Run bootstrap (installs dependencies)
./bootstrap.sh

# Run interactive installation
./install.sh

# Restart your shell
exec zsh
```

## Requirements

- Git
- curl
- Zsh (will be installed if missing)
- Homebrew (macOS) (will be installed if missing) or package manager (Linux)

## Repository Structure

```
configs/
├── README.md
├── bootstrap.sh                   # Initial setup and dependencies
├── install.sh                     # Interactive installation
├── Brewfile                       # Homebrew dependencies (macOS)
├── lib/                          # Utility libraries
│   ├── platform.sh               # Platform detection
│   ├── logging.sh                # Logging utilities
│   └── symlink.sh                # Symlink management
├── config/
│   ├── zsh/                      # Zsh configuration
│   │   ├── zshrc                 # Main entry point
│   │   ├── zshenv                # Environment variables
│   │   ├── aliases.zsh           # Shell aliases
│   │   ├── completion.zsh        # Completion config
│   │   ├── history.zsh           # History settings
│   │   ├── keybindings.zsh       # Key bindings
│   │   └── plugins/              # Plugin configurations
│   ├── starship/
│   │   └── starship.toml         # Starship prompt config
│   ├── nvim/
│   │   └── init.vim              # Neovim config
│   ├── git/
│   │   ├── gitconfig.template    # Git config template
│   │   ├── gitignore_global      # Global gitignore
│   │   └── git-template/hooks/   # Git hooks
│   └── uv/
│       └── uv.toml.template      # UV Python manager config
├── functions/                     # Public shell functions
│   └── fzf_open                  # FZF file opener
├── scripts/                       # Setup scripts
│   ├── setup-homebrew.sh
│   └── setup-zsh-plugins.sh
└── private/                       # Git submodule
    └── (enterprise-specific configs)
```

## Git Conditional Configuration

This setup uses Git's conditional includes to automatically apply different configurations based on repository location:

**Personal projects** (anywhere):
- Uses personal email from base `~/.gitconfig`
- Personal settings and aliases

**Work projects** (`~/<enterprise_name>/projects/`):
- Automatically loads `~/configs/private/config/git/gitconfig-<enterprise_name>`
- Uses corporate email

### How it works

```gitconfig
# Base ~/.gitconfig
[user]
    email = your-personal@domain.tld

# Conditional include - loads ONLY in ~/<enterprise_name>/projects/
[includeIf "gitdir:~/<enterprise_name>/projects/"]
    path = ~/configs/private/config/git/gitconfig-<enterprise_name>
```

No manual configuration per repo needed - Git automatically detects the directory!

## UV Python Package Manager

This setup uses [UV](https://github.com/astral-sh/uv) instead of pip for modern, fast Python package management.

## Customization

### Machine-specific settings

Create `~/.config/zsh/local.zsh` for machine-specific configurations:

```zsh
# Example: local.zsh
export PATH="/custom/path:$PATH"
alias mylocal='echo "Machine-specific alias"'
```

This file is sourced last and is gitignored.

### Private Submodule

Enterprise-specific configurations are stored in a private submodule at `private/`:

- Enterprise functions
- Work-specific completions
- SSH configurations
- Enterprise git settings

See [private/README.md](private/README.md) for details.

## Key Features

### Modular Zsh Configuration

Direct plugin loading:

- `aliases.zsh` - Shell aliases including useful git shortcuts
- `completion.zsh` - Completion configuration
- `history.zsh` - History settings
- `plugins/fzf.zsh` - FZF fuzzy finder
- `plugins/direnv.zsh` - direnv integration
- `plugins/zoxide.zsh` - Smart directory jumping
- `plugins/zsh-plugins.zsh` - Autosuggestions & syntax highlighting

## Platform Support

### macOS
- Homebrew package management
- 1Password SSH agent support
- Apple Silicon and Intel support

### Linux
- apt (Ubuntu/Debian)
- dnf (Fedora/RHEL)
- pacman (Arch)
- Manual installations for starship, zoxide, UV

## Verification

After installation, verify your setup:

```bash
# Shell loads successfully
zsh -i -c 'echo "Shell loaded"'

# Starship prompt
starship --version

# Aliases
alias | grep git

# Functions
type fzf_open

# Git configuration
git config --list

# Test conditional git config
cd ~/personal-project
git config user.email  # Should show personal email

cd ~/<enterprise_name>/projects/work-repo
git config user.email  # Should show corporate email
```

## Troubleshooting

### Starship not showing

Ensure starship is installed and in PATH:
```bash
which starship
starship --version
```

### Plugins not loading

Check plugin paths match your installation:
```bash
# macOS
brew --prefix zsh-autosuggestions
brew --prefix zsh-syntax-highlighting

# Linux
ls /usr/share/zsh-autosuggestions/
ls /usr/share/zsh-syntax-highlighting/
```

### Git conditional config not working

Verify the path in `.gitconfig`:
```bash
cat ~/.gitconfig | grep includeIf
```

Ensure the path uses `gitdir:` and matches your project location.

## Uninstallation

To remove the dotfiles, run the uninstall script:

```bash
cd ~/configs
./uninstall.sh
```

The script will:
- Remove all symlinks safely
- Show available backups
- Prompt for removal of generated configs (.gitconfig, .ssh/config)
- Optionally remove the repository
