#!/usr/bin/env bash

# Unregister proj
proj_remove()
{
    # bold "@" "$@"

    # Check if 1st parameter (proj name) empty
    test empty $1 \
        --te "$(err "No project name given to be added.\nUse 'dm project remove --help' for more information.")" \
        --txit

    local PROJ_DIR="$(__proj_get_dir_by_name "$1")"

    # Check if proj directory exists
    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Project directory of '$1' not found.")" \
        --fxit

    # Unmapping proj in ./MAP file
    test __proj_map_remove "$PROJ_DIR" \
        --te "$(success "Project '$1' is unregistered.")" \
        --fe "$(err "Unable to unregister project '$1'")"
}