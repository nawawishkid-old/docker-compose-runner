#!/usr/bin/env bash

#####
# Private functions
#####
__proj_map_get()
{
    local DIR="$(cat $PROJECT_MAP | grep -P "^$1=")"

    # bold "1" "$1"
    # bold "2" "$2"
    # bold "DIR" "$DIR"

    if [ "$DIR" != "" ]; then
        echo "$DIR"
        return 0
    fi

    DIR="$(cat $PROJECT_MAP | grep -P "=$2$")"

    if [ "$DIR" != "" ]; then
        echo "$DIR"
        return 0
    fi
    
    return 1
}

__proj_cd()
{
    local PROJ_DIR="$(__proj_map_get "$1" | cut -d= -f2 -s)"

    # bold "PROJ_DIR" "$PROJ_DIR"

    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Project directory of '$1' not found.")" \
        --fxit

    test cd "$PROJ_DIR" \
        --fe "$(err "Cannot access to the proj directory.")" \
        --fxit
}