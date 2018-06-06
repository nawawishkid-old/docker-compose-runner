#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ./compose.sh

project()
{
    # Check if 1st parameter (project command) empty
    test empty $1 \
        --te "$(err "No command given.\nUse 'dm project help' for more information.")" \
        --txit

    while [ $# -ne 0 ]; do
        case "$1" in
            help | --help)
                echo "help!"
            ;;
            add)
                import 'project/add'
                shift
                project_add "$@"
                exit
            ;;
            remove)
                import 'project/remove'
                shift
                project_remove "$@"
                exit
            ;;
            ps)
                import 'project/ps'
                shift
                project_ps "$@"
                exit
            ;;
        esac

        shift

    done
}