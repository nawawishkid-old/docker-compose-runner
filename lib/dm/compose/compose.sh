#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ../main.sh

COMPOSE_DIR="${ROOTDIR}/compose"
COMPOSE_PROJECTS_DIR="${COMPOSE_DIR}/projects"
COMPOSE_TEMPLATES_DIR="${COMPOSE_DIR}/templates"

# Main function
compose()
{

    while [ $# -ne 0 ]; do
        case "$1" in
            build)
                import "compose/build"
                shift
                compose_build "$@"
                exit
                ;;
            delete)
                import "compose/delete"
                shift
                compose_delete "$@"
                ;;
            ls)
                import "compose/ls"
                compose_ls
                exit
                ;;
            up)
                import "compose/up"
                shift
                compose_up "$1"
                ;;
            down)
                import "compose/down"
                shift
                compose_down "$1"
                ;;
            start)
                import "compose/start"
                shift
                compose_start "$1"
                ;;
            stop)
                import "compose/stop"
                shift
                compose_stop "$1"
                ;;
            restart)
                import "compose/restart"
                shift
                compose_restart "$1"
                ;;
            help | --help )
                help_compose
                exit
                ;;
        esac
        
        shift

    done
}

#####
# Private functions
#####
__compose_project_name_is_valid()
{
    echo "$1" | grep -oP "^\w{1}[\w-_]*"

    return $?
}

__compose_get_project_dir()
{
    echo "${COMPOSE_PROJECTS_DIR}/${1}"
}

__compose_if_project_exists_by_dir()
{
    [[ -d "$1" || -f "${1}/docker-compose.yml" ]]
}

__compose_cd_project()
{
    test cd "$1" \
        --fe "$(err "Cannot access to the project directory.")" \
        --fxit
}