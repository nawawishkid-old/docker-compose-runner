#!/usr/bin/env bash

project_add()
{
    # bold "@" "$@"

    # Check if 1st parameter (project name) empty
    test empty $1 \
        --te "$(err "No project name given to be added.\nUse 'dm project add help' for more information.")" \
        --txit

    # Check if 2nd parameter (directory path) empty
    test empty $2 \
        --te "$(err "No Docker Compose directory path given to be added.\nUse 'dm project add --help' for more information.")" \
        --txit

    local NAME="$1"
    local PROJ_DIR="$2"
    local OVERRIDE=1

    shift 2

    while [ $# -ne 0 ]; do
        case "$1" in
            help | --help)
                ;;
            -o | --override)
                OVERRIDE=0
                ;;
        esac

        shift

    done

    # bold "NAME" "$NAME"
    # bold "PROJ_DIR" "$PROJ_DIR"
    bold "OVERRIDE" "$OVERRIDE"

    # Check if project already exists by given name
    __project_exists "$NAME" "$PROJ_DIR"
    
    [[ $? -eq 0 && $OVERRIDE -eq 1 ]]

    test $? \
        --te "If you want to override existing project, run this command again with --override flag to override. Exit." \
        --txit
    
    # Check if given name is a valid project name
    test __project_name_is_valid "$NAME" \
        --fe "$(err "Invalid project name '$NAME'.\n\nValid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore.")" \
        --fxit

    # Check if given directory exists
    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Given directory path '$PROJ_DIR' does not exists.")" \
        --fxit

    # Write MAP file
    if [ $OVERRIDE -eq 0 ]; then
        test __project_map_override "$NAME" "$PROJ_DIR" \
            --te "$(success "Project '$NAME' is overridden.")" \
            --fe "$(err "Failed to override project '$NAME'")"
    else
        test __project_map_add "$NAME" "$PROJ_DIR" \
            --te "$(success "Project '$NAME' added.")" \
            --fe "$(err "Failed to add project '$NAME'")"
    fi
}