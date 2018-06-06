#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ./compose.sh

compose_down()
{
    # Check if 1st parameter (project name) empty
    test empty $1 \
        --te "$(err "Missing project name: ${APP_NAME} compose down PROJECT_NAME")" \
        --txit

    local NAME="$1"
    local PROJ_DIR="$(__compose_get_project_dir "$NAME")"

    # Check if project exists using given name
    test __compose_if_project_exists_by_dir "$PROJ_DIR" \
        --fe "$(err "Project name '$NAME' not found.")" \
        --fxit

    # cd to the directory
    __compose_cd_project "$PROJ_DIR"

    # Down the project
    test docker-compose down \
        --te "$(success "Project '$NAME' is down.")"
        --fe "$(err "Cannot down the project.")"
    
    exit
}