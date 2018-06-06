#!/usr/bin/env bash

APP_NAME="dm"
ROOTDIR=${PWD}
LOG_DIR="${ROOTDIR}/log/dm"
PROJECT_MAP="${APP_SOURCE_DIR}/project/MAP"

[ -z "$APP_SOURCE_DIR" ] && APP_SOURCE_DIR="."

source ${APP_SOURCE_DIR}/utils.sh
import "output"
import "help/main"
import "project/private"

test empty $1 --txec "help_all" --txit

# Main function
# Usage: dm compose [options] COMMAND NAME [options]
main()
{
    local COMPOSE_OPTS=()
    local COMMAND_OPTS=()
    local SWITCHED=1
    local COMMAND=""
    local NAME=""

    while [ $# -ne 0 ]; do
        case "$1" in
            help | --help )
                help_compose
                exit
            ;;
            build | bundle | config | \
            create | down | events | \
            exec | kill | logs | \
            pause | port | ps | \
            pull | push | restart | \
            rm | run | scale | \
            start | stop | top | \
            unpause | up )
                SWITCHED=0
                COMMAND="$1"
                shift
                NAME="$1"
                # echo "COMMAND: $1"
            ;;
            project)
                import "project/project"
                shift
                project "$@"
                exit
            ;;
            -* | --*)
                if [ $SWITCHED -eq 0 ]; then COMMAND_OPTS+=("$1")
                else COMPOSE_OPTS+=("$1")
                fi
            ;;
            *)
                err "Unknown argument '$1'\nUse '${APP_NAME} help' for more information."
                exit
            ;;
        esac
        
        shift

    done

    # bold "COMPOSE_OPTS" "${COMPOSE_OPTS[@]}"
    # bold "COMMAND_OPTS" "${COMMAND_OPTS[@]}"
    # bold "SWITCHED" "$SWITCHED"
    # bold "NAME" "$NAME"

    # Check if COMMAND given
    test empty "$COMMAND" \
        --te "$(err "No command given\nUse 'dm compose help' for more information.")" \
        --txit

    # Check if PROJECT_NAME given
    test empty "$NAME" \
        --te "$(err "No project name given\nUse 'dm compose help' for more information.")" \
        --txit

    # Check if project exists.
    test __project_exists_by_name "$NAME" \
        --fe "$(err "Project '$NAME' not found.")" \
        --fxit

    # cd to the project
    __project_cd "$NAME"

    # Run docker-compose
    test docker-compose "${COMPOSE_OPTS[@]}" "$COMMAND" "${COMMAND_OPTS[@]}" \
        --te "$(success)" \
        --fe "$(err)"

    exit
}

#####
# Executions
#####
main "$@"