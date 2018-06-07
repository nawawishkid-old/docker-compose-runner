#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ../main.sh

project()
{
    # Check if 1st parameter (project command) empty
    test empty $1 \
        --te "$(err "No command given." "project")" \
        --txit

    while [ $# -ne 0 ]; do
        case "$1" in
            help | --help)
                help "project"
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