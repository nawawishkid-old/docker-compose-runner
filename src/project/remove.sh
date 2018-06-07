#!/usr/bin/env bash

# Unregister project
project_remove()
{
    # bold "@" "$@"

    # Check if 1st parameter (project name) empty
    test empty $1 \
        --te "$(err "No project name given to be added.\nUse 'dm project remove --help' for more information.")" \
        --txit

    local PROJ_DIR="$(__project_get_dir_by_name "$1")"

    # Check if project directory exists
    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Project directory of '$1' not found.")" \
        --fxit

    # Unmapping project in ./MAP file
    test __project_map_remove "$PROJ_DIR" \
        --te "$(success "Project '$1' is unregistered.")" \
        --fe "$(err "Unable to unregister project '$1'")"
}