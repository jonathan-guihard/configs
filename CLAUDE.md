# Dotfiles Repository

Personal dotfiles with a public/private split architecture. The public repo is on GitHub; `private/` is a git submodule (not publicly accessible).

## Public vs Private Rule

**Before creating or modifying any script, config, completion, function, or dependency: ask the user whether it should be public or private.**

### What goes where

| Type             | Public (this repo)        | Private (`private/` submodule)   |
| ---------------- | ------------------------- | -------------------------------- |
| Scripts/binaries | `bin/` (create if needed) | `private/bin/`                   |
| Zsh functions    | `functions/*.zsh`         | `private/functions/`             |
| Zsh completions  | `completions/_<name>`     | `private/completions/_<name>`    |
| Config files     | `config/<tool>/`          | `private/config/<tool>/`         |
| Brew packages    | `Brewfile`                | `private/Brewfile`               |
| Pip dependencies | `requirements.txt`        | `private/requirements.txt`       |
| Zsh shell config | `config/zsh/*.zsh`        | `private/config/zsh/private.zsh` |
| Install logic    | `install.sh`              | `private/install.sh`             |

### Key principles

- **Never expose private content in public files.** No tool-specific names, paths, secrets, or company details in `install.sh`, `bootstrap.sh`, or any public file.
- `install.sh` handles private setup **generically**: it loops over `private/functions/`, `private/completions/`, and calls `private/install.sh` — without knowing what's inside.
- Tool-specific private install steps (symlinks, config, etc.) go in `private/install.sh`.
- Aliases, env vars, and secrets for private tools go in `private/config/zsh/private.zsh`.
- Secrets must use 1Password CLI (`op read "op://..."`) — never hardcode credentials.

## Repository Structure

```
configs/                      # Public dotfiles (GitHub)
├── bootstrap.sh              # Initial setup: brew, git submodules, system deps
├── install.sh                # Symlinks, config generation, calls private/install.sh
├── uninstall.sh
├── Brewfile                  # Public brew packages
├── requirements.txt          # Public pip dependencies
├── config/                   # Public tool configs
│   ├── zsh/                  # zshrc, aliases, plugins, completions, keybindings
│   ├── git/
│   ├── starship/
│   ├── nvim/
│   ├── ghostty/
│   ├── zed/
│   └── uv/
├── functions/                # Public zsh functions (auto-sourced)
├── completions/              # Public zsh completions (symlinked to ~/.zsh_completions)
├── lib/                      # Shared bash utilities (logging.sh, platform.sh, symlink.sh)
├── scripts/                  # Setup helper scripts
├── local/                    # Machine-specific overrides (not committed)
└── private/                  # Git submodule — enterprise/company-specific
    ├── install.sh            # Private install steps (symlinks, pip deps)
    ├── Brewfile              # Private brew packages
    ├── requirements.txt      # Private pip dependencies
    ├── bin/                  # Private scripts (added to PATH via private.zsh)
    ├── completions/          # Private zsh completions
    ├── functions/            # Private zsh functions
    └── config/
        ├── zsh/private.zsh   # Aliases, env vars, secrets (sourced by zshrc)
        ├── ssh/
        ├── uv/
        └── .../
```

## Installation Flow

1. `bootstrap.sh` — installs brew, system packages, git submodules, etc..
2. `install.sh` — symlinks configs, links functions/completions, installs pip deps, calls `private/install.sh`
3. `private/install.sh` — private-specific symlinks and pip deps

## Adding a New Tool

When the user asks to add a new tool/script/config, follow this checklist:

1. **Ask: public or private?**
2. **Script/binary**: place in `bin/` or `private/bin/` (private bins are on PATH via `private.zsh`)
3. **Config file**: place in `config/<tool>/` or `private/config/<tool>/`
4. **Zsh completion**: place in `completions/` or `private/completions/` (auto-symlinked by `install.sh`)
5. **Zsh function**: place in `functions/` or `private/functions/` (auto-sourced)
6. **Alias/env vars**: add to `config/zsh/aliases.zsh` or `private/config/zsh/private.zsh`
7. **Brew package**: add to `Brewfile` or `private/Brewfile`
8. **Pip dependency**: add to `requirements.txt` or `private/requirements.txt`
9. **Install-time setup** (symlinks, config generation): add to `install.sh` generically or `private/install.sh` for private-specific steps
10. **Secrets**: always use `op read` in `private/config/zsh/private.zsh`, never hardcode

## Conventions

- Shared bash utilities live in `lib/` — use `source "${DOTFILES_DIR}/lib/logging.sh"` etc.
- Logging functions: `info`, `success`, `warn`, `error`, `section`
- Symlink helper: `create_symlink <source> <target>` (backs up existing files)
- Directory helper: `create_dir_if_missing <path>`
- Platform detection: `is_macos`, `is_linux`, `detect_platform`
- When a command needs zsh completion, use a **function** (not an alias) + `compdef`. Aliases bypass completion because zsh expands them before running the completion system. Pattern: `cmd() { python3 /path/to/script.py "$@" }` + `compdef _cmd cmd`
