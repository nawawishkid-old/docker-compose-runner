#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ./compose.sh

compose_build()
{
    # Check if 1st parameter (project name) empty
    test empty $1 \
        --te "$(err "Missing project name: ${APP_NAME} compose build <project_name> <template_name> [options]")" \
        --txit

    # Check if 2nd parameter (template name) empty
    test empty $2 \
        --te "$(err "Missing project template name: ${APP_NAME} compose build <project_name> <template_name> [options]")" \
        --txit

    local NAME="$1"
    local TEMPLATE_NAME="$2"
    local TEMPLATE_DIR="${COMPOSE_TEMPLATES_DIR}/${TEMPLATE_NAME}"
    local PROJ_DIR="${COMPOSE_PROJECTS_DIR}/${NAME}"
    local OVERRIDE=1

    shift 2

    while [ $# -ne 0 ]
    do
        case "$1" in
            --override)
                OVERRIDE=0
            ;;
        esac
        
        shift

    done

    # bold "\n NAME" "$NAME"
    # bold " TEMPLATE_NAME" "$TEMPLATE_NAME"
    # bold " TEMPLATE_DIR" "$TEMPLATE_DIR"
    # bold " PROJ_DIR" "$PROJ_DIR"
    # bold " OVERRIDE" "$OVERRIDE\n"
    
    # Check if project already exists using given name
    [[ -d "$PROJ_DIR" || -f "${PROJ_DIR}/docker-compose.yml" ]]
    test $? \
        --te "$(warn "Project name '$NAME' already exists.")"

    # Tell user that they can use --override to override existing project
    [[ $? -eq 0 && $OVERRIDE -eq 1 ]]
    
    test $? \
        --te "If you want to override existing project, run this command again with --override flag to override. Exit." \
        --txit

    # Check if given name is a valid project name
    test __compose_project_name_is_valid "$NAME" \
        --fe "$(err "Invalid project name '$NAME'. Valid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore.")" \
        --fxit

    # Check if specified template exists
    test file_exists "${TEMPLATE_DIR}/template.yml" \
        --fe "$(err "Template '$TEMPLATE_NAME' not found.")" \
        --te "Building project from '$TEMPLATE_NAME' template..." \
        --fxit

    # Copy template directory
    test cp -r $TEMPLATE_DIR $PROJ_DIR \
        --fe "$(err "Failed to create project directory by copying template directory.")" \
        --fxit
    
    # Rename template.yml to docker-compose.yml
    test mv "${PROJ_DIR}/template.yml" "${PROJ_DIR}/docker-compose.yml" \
        --fe "$(err "Failed to rename project compose file from 'template.yml' to 'docker-compose.yml'.")" \
        --te "$(success "The project '$NAME' was built successfully!")" \
        --fxit
}