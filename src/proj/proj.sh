#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ../main.sh

proj()
{
    # Check if 1st parameter (proj command) empty
    test empty $1 \
        --te "$(err "No command given." "proj")" \
        --txit

    while [ $# -ne 0 ]; do
        case "$1" in
            help | --help)
                help "proj"
            ;;
            add)
                import 'proj/add'
                shift
                proj_add "$@"
                exit
            ;;
            remove)
                import 'proj/remove'
                shift
                proj_remove "$@"
                exit
            ;;
            ps)
                import 'proj/ps'
                shift
                proj_ps "$@"
                exit
            ;;
        esac

        shift

    done
}