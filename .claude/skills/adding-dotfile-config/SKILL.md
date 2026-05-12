---
name: adding-dotfile-config
description: Use when adding a new tool, script, binary, zsh function, zsh completion, config file, alias, env var, brew package, or pip dependency to the ~/configs dotfiles repo. Triggers on requests like "add X", "install X", "configure X", "set up X for me", or any edit to Brewfile, requirements.txt, install.sh, or files under config/, functions/, completions/, bin/.
---

# Adding a New Tool or Config to the Dotfiles Repo

## Core Rule

**ASK FIRST: "Should this be public or private?"**

The repo has a strict public/private split. `~/configs/` is a public GitHub repo. `~/configs/private/` is a separate git submodule with enterprise/company content that must never leak into public files.

Never guess. Ask the user before touching any file. If the user names a company tool, a work hostname, an internal URL, or anything specific to their employer, the answer is almost certainly **private** — but still confirm.

## Routing Table

| Adding...           | Public path                  | Private path                                |
| ------------------- | ---------------------------- | ------------------------------------------- |
| Script / binary     | `bin/<name>`                 | `private/bin/<name>`                        |
| Zsh function        | `functions/<name>.zsh`       | `private/functions/<name>.zsh`              |
| Zsh completion      | `completions/_<name>`        | `private/completions/_<name>`               |
| Tool config         | `config/<tool>/`             | `private/config/<tool>/`                    |
| Brew package        | `Brewfile`                   | `private/Brewfile`                          |
| Pip dependency      | `requirements.txt`           | `private/requirements.txt`                  |
| Alias / env var     | `config/zsh/aliases.zsh`     | `private/config/zsh/private.zsh`            |
| Secret / credential | Using `op read`              | Using `op read`                             |
| Install-time setup  | `install.sh` (generic only)  | `private/install.sh`                        |

## Public Hygiene

Public files (`install.sh`, `bootstrap.sh`, `Brewfile`, `config/**`, `functions/**`, `completions/**`, `bin/**`, `README.md`, `CLAUDE.md`) must stay generic. No tool names from `private/`, no employer references, no specific paths into `private/config/<tool>/`.

Public install logic loops over `private/functions/`, `private/completions/`, etc., and delegates everything tool-specific to `private/install.sh`. If you find yourself about to write `if [[ <tool-name> ]]` or `create_symlink "$DOTFILES_DIR/private/config/<tool>/..."` in `install.sh`, **stop** — that belongs in `private/install.sh`.

## How Things Get Wired

- `bin/` and `private/bin/` are on `PATH` (via `config/zsh/zshenv` and `private.zsh`). No install step needed for new binaries.
- Files in `functions/` and `private/functions/` are symlinked to `~/.zsh_functions/` by `install.sh` and auto-sourced from `zshrc`.
- Files in `completions/` and `private/completions/` are symlinked to `~/.zsh_completions/` by `install.sh`.
- `private/config/zsh/private.zsh` is sourced from `config/zsh/zshrc` when present.
- Tool-generated completions (`mise completion zsh`, etc.) go in `config/zsh/completion.zsh` before `compinit` — **not** in `install.sh` — so they refresh on every shell start.
- New brew packages and pip deps need no install wiring: `install.sh` and `private/install.sh` already pick them up from `Brewfile` / `requirements.txt`.

Special install-time setup (symlink at a specific path, template substitution, post-install hook) is the only case that needs new code in an install script:
- Generic + public-safe → `install.sh`
- Tool- or employer-specific → `private/install.sh`

## Completions Require a Function, Not an Alias

When a command needs zsh completion, define a **function** + `compdef`. Aliases break completion because zsh expands them before completion runs.

```zsh
mycmd() { python3 /path/to/script.py "$@" }
compdef _mycmd mycmd
```

## Secrets

Never hardcode credentials anywhere — including inside `private/`.

## Workflow

1. Ask the user: **public or private?**
2. Pick the path from the routing table.
3. Create the file (script, function, completion, config) in the chosen location.
4. If it's a command needing tab-completion, write a wrapper function + `compdef`, not an alias.
5. If a brew/pip dependency is needed, add it to the matching `Brewfile` / `requirements.txt`.
6. If aliases or env vars are needed for a private tool, add them to `private/config/zsh/private.zsh`.
7. If install-time setup is needed (symlink, template), add it to `install.sh` (generic) or `private/install.sh` (specific).
8. If you edited `install.sh`, re-read the diff and confirm no private tool names or paths leaked into public code.
9. Tell the user how to apply the change (re-run `install.sh`, `brew bundle`, or `exec zsh` depending on what was touched).

## Red Flags — Stop and Reroute

| Symptom                                                              | What it means                                  |
| -------------------------------------------------------------------- | ---------------------------------------------- |
| Writing tool-specific `if`/symlink logic in `install.sh`              | Move to `private/install.sh`                   |
| Hardcoding a credential anywhere                                      | Use `op read` from `private.zsh`               |
| Creating `bin/<script>` when the user mentioned a company name        | It's almost certainly private                  |
| Adding `compdef` for an alias                                         | Convert to a function first                    |
| Touching public `Brewfile` for a tool whose config lives in `private/` | Wrong Brewfile — use `private/Brewfile`        |
| Putting a tool-generated completion command in `install.sh`           | It belongs in `config/zsh/completion.zsh`      |
| Adding a public `config/<tool>/` for something only used at work      | Should be `private/config/<tool>/`             |
