#!/usr/bin/env bash

#####
# Private functions
#####
__project_cd()
{
    local PROJ_DIR="$(__project_map_get "$1" | cut -d= -f2 -s)"

    # bold "PROJ_DIR" "$PROJ_DIR"

    test dir_exists "$PROJ_DIR" \
        --fe "$(err "Project directory of '$1' not found.")" \
        --fxit

    test cd "$PROJ_DIR" \
        --fe "$(err "Cannot access to the project directory.")" \
        --fxit
}
__project_name_is_valid()
{
    echo "$1" | grep -oP "^\w{1}[\w-_]*"

    return $?
}

# __project_get_project_dir()
# {
    # echo "${COMPOSE_PROJECTS_DIR}/${1}"
# }

__project_get_dir_from_map()
{
    cat "$PROJECT_MAP" | grep -oqP "(?<==).*"
}

# __project_if_project_exists_by_dir()
# {
#     [[ -d "$1" || -f "${1}/docker-compose.yml" ]]
# }

__project_cd()
{
    local PROJ_DIR="$(__project_map_get "$1" | cut -d= -f2 -s)"

    test cd "$PROJ_DIR" \
        --fe "$(err "Cannot access to the project directory.")" \
        --fxit
}

__project_exists_by_name()
{
    cat $PROJECT_MAP | grep -oqP "^$1(?==)"
}

__project_exists_by_dir()
{
    cat $PROJECT_MAP | grep -oqP "^(?<==)$2$"
}

__project_exists()
{
    __project_exists_by_name "$1"
    
    if [ $? -eq 0 ]; then
        warn "Project '$1' already exists."
        return 0
    fi

    # [ "$2" = "" ] && exit 1

    __project_exists_by_name "$2"
    
    if [ $? -eq 0 ]; then
        warn "Given directory '$2' already belongs to another project."
        return 0
    fi

    return 1
}

__project_map_get()
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

__project_map_add()
{
    # bold "MAP" "${1}=${2}"
    # bold "PROJECT_MAP" "$PROJECT_MAP"

    echo "${1}=${2}" >> "$PROJECT_MAP"
}

__project_map_override()
{
    local MAPPED="$(__project_map_get "$1" "$2")"

    # bold "MAPPED" "$MAPPED"

    sed -i "s,$MAPPED,${1}=${2},g" $PROJECT_MAP
}

__project_map_remove()
{
    sed -i "\,$1,d" $PROJECT_MAP
}