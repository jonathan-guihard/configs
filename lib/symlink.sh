#!/usr/bin/env bash
# Symlink creation utilities

source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

create_symlink() {
    local source="$1"
    local target="$2"

    # Ensure source exists
    if [[ ! -e "$source" ]]; then
        error "Source does not exist: $source"
        return 1
    fi

    # Backup if target exists and is not already the correct symlink
    if [[ -e "$target" || -L "$target" ]]; then
        # Check if it's already the correct symlink
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            info "Symlink already exists: $target -> $source"
            return 0
        fi

        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        warn "Backing up existing file: $target -> $backup"
        mv "$target" "$backup"
    fi

    # Create parent directory
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
    fi

    # Create symlink
    ln -sf "$source" "$target"

    if [[ $? -eq 0 ]]; then
        success "Created symlink: $target -> $source"
        return 0
    else
        error "Failed to create symlink: $target -> $source"
        return 1
    fi
}

create_dir_if_missing() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        info "Created directory: $dir"
    fi
}
