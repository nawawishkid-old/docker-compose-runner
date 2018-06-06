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
                test empty $1 --te "$(err "Missing compose project name argument: ${APP_NAME} compose delete <project-name>")" --txit
                
                compose_delete "$@"
                exit
                ;;
            ls)
                import "compose/ls"
                compose_ls
                exit
                ;;
            up)
                import "compose/up"
                shift
                test empty $1 --te "$(err "Missing compose project name argument: ${APP_NAME} compose up <project-name>")" --txit
                
                compose_up "$1"
                ;;
            down)
                import "compose/down"
                shift
                test empty $1 --te "$(err "Missing compose project name argument: ${APP_NAME} compose down <project-name>")" --txit
                
                compose_down "$1"
                ;;
            start)
                import "compose/start"

                ;;
            stop)
                import "compose/stop"
                
                ;;
            restart)
                import "compose/restart"

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