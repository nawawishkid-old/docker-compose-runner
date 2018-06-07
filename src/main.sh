#!/usr/bin/env bash

APP_NAME="dm"
ROOTDIR=${PWD}
PROJECT_MAP="${APP_SOURCE_DIR}/proj/MAP"
DOC_DIR="${APP_SOURCE_DIR}/doc"

# Set APP_SOURCE_DIR
[ -z "$APP_SOURCE_DIR" ] && APP_SOURCE_DIR="."

# Import dependencies
source ${APP_SOURCE_DIR}/utils.sh
import "output"
import "proj/private"

# If no argument given, echo help text
test empty $1 --txec "help main" --txit

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
                help "main"
                exit
            ;;
            # Original `docker-compose` commands
            build | bundle | config | \
            create | down | events | \
            exec | kill | logs | \
            pause | port | ps | \
            pull | push | restart | \
            rm | run | scale | \
            start | stop | top | \
            unpause | up )
                # If the loop iterate to this point, that means all the next option arguments are options for command of `docker-compose`, not `docker-compose` itself.
                # So, I switched it to mark that.
                SWITCHED=0
                COMMAND="$1"
                shift

                echo "$1" | grep -oq "\-\-"

                if [ $? -eq 0 ]; then
                    warn "This is not 'dm' help text.\nIt's an original 'docker-compose' help text.\n"
                    
                    docker-compose "$COMMAND" --help
                    exit
                else
                    NAME="$1"
                fi
                # echo "COMMAND: $1"
            ;;
            proj)
                import "proj/proj"
                shift
                proj "$@"
                exit
            ;;
            *)
                if [ $SWITCHED -eq 0 ]; then COMMAND_OPTS+=("$1")
                else COMPOSE_OPTS+=("$1")
                fi
            ;;
            # *)
            #     err "Unknown argument '$1'."
            #     exit
            # ;;
        esac
        
        shift

    done

    # Codes below are for an execution of any `docker-compose` command.

    bold "COMPOSE_OPTS" "${COMPOSE_OPTS[@]}"
    bold "COMMAND_OPTS" "${COMMAND_OPTS[@]}"
    bold "SWITCHED" "$SWITCHED"
    bold "NAME" "$NAME"

    # Check if COMMAND given
    test empty "$COMMAND" \
        --te "$(err "No command given.")" \
        --txit

    # Check if PROJECT_NAME given
    test empty "$NAME" \
        --te "$(err "No project name given.")" \
        --txit

    # Check if given proj exists.
    test __proj_exists_by_name "$NAME" \
        --fe "$(err "Project '$NAME' not found.")" \
        --fxit

    # cd to the proj
    __proj_cd "$NAME"

    # Run docker-compose command
    echo "docker-compose -p $NAME "${COMPOSE_OPTS[@]}" "$COMMAND" "${COMMAND_OPTS[@]}""
    test docker-compose "${COMPOSE_OPTS[@]}" "$COMMAND" "${COMMAND_OPTS[@]}" \
        --te "$(success)"

    exit
}

#####
# Executions
#####
# Don't forget to run me!
main "$@"