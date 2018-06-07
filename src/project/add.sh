#!/usr/bin/env bash

# Register project
project_add()
{
    # bold "@" "$@"

    # Check if 1st parameter (project name) empty
    test empty $1 \
        --te "$(err "No project name given to be added." "project add")" \
        --txit

    [ "$1" = "--help" ]

    test $? \
        --txec "help project_add" \
        --txit

    # Check if 2nd parameter (directory path) empty
    test empty $2 \
        --te "$(err "No Docker Compose directory path given to be added.\nUse 'dm project add --help' for more information.")" \
        --txit

    local NAME="$1"
    local PROJ_DIR="$(__project_escape_dir_path "$2")"
    local OVERRIDE=1
    local PROJECT_EXISTS=1

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
    # bold "OVERRIDE" "$OVERRIDE"

    # Check if project already exists by given name
    __project_exists "$NAME" "$PROJ_DIR"

    PROJECT_EXISTS=$?
    
    # Check if given name is a valid project name
    test __project_name_is_valid "$NAME" \
        --fe "$(err "Invalid project name '$NAME'.\n\nValid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore.")" \
        --fxit

    # Check if given directory exists
    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Given directory path '$PROJ_DIR' does not exists.")" \
        --fxit

    if [ $PROJECT_EXISTS -eq 0 ]; then
        if [ $OVERRIDE -eq 1 ]; then
            # If they don't intend to override, tell them that they can
            echo "If you want to override existing project, run this command again with --override flag to override. Exit."
            exit
        fi

        # Override existing mapping data in ./MAP
        test __project_map_override "$NAME" "$PROJ_DIR" \
            --te "$(success "Project '$NAME' is overridden.")" \
            --fe "$(err "Failed to override project '$NAME'")"

        exit
    fi

    # Append a new mapping data to ./MAP file
    test __project_map_add "$NAME" "$PROJ_DIR" \
        --te "$(success "Project '$NAME' added.")" \
        --fe "$(err "Failed to add project '$NAME'")"

    exit
}

# Check if project exists, specifically for project_add()
__project_exists()
{
    # bold "1" "$1"
    # bold "2" "$2"

    __project_exists_by_name "$1"
    
    if [ $? -eq 0 ]; then
        warn "Project '$1' already exists."
        return 0
    fi

    # echo "by name not found."

    __project_exists_by_dir "$2"
    
    if [ $? -eq 0 ]; then
        warn "Given directory '$2' already belongs to another project."
        return 0
    fi

    
    return 1
}