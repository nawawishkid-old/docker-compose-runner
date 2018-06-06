#!/usr/bin/env bash

COMPOSE_DIR="${ROOTDIR}/compose"
COMPOSE_PROJECTS_DIR="${COMPOSE_DIR}/projects"
COMPOSE_TEMPLATES_DIR="${COMPOSE_DIR}/templates"

# Main function
compose()
{

    while [ "$1" != "" ]
    do
        case "$1" in
            build)
                shift
                compose_build "$@"
                exit
                ;;
            delete)
                shift
                test empty $1 --te "\033[1;31mERROR:\033[0m Missing compose project name argument: ${APP_NAME} compose delete <project-name>" --txit
                
                compose_delete "$@"
                exit
                ;;
            ls)
                compose_ls
                exit
                ;;
            up)
                shift
                test empty $1 --te "\033[1;31mERROR:\033[0m Missing compose project name argument: ${APP_NAME} compose up <project-name>" --txit
                
                compose_up "$1"
                ;;
            down)
                shift
                test empty $1 --te "\033[1;31mERROR:\033[0m Missing compose project name argument: ${APP_NAME} compose down <project-name>" --txit
                
                compose_down "$1"
                ;;
            start)

                ;;
            stop)
                
                ;;
            restart)

                ;;
            help | --help )
                help_compose
                exit
                ;;
        esac
        
        shift

    done
}

compose_build()
{
    # Check if 1st parameter (project name) empty
    test empty $1 --te "\033[1;31mERROR:\033[0m Missing project name: ${APP_NAME} compose build <project_name> <template_name> [options]" --txit

    # Check if 2nd parameter (template name) empty
    test empty $2 --te "\033[1;31mERROR:\033[0m Missing project template name: ${APP_NAME} compose build <project_name> <template_name> [options]" --txit

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

    out_pair "\n NAME" "$NAME" bold
    out_pair " TEMPLATE_NAME" "$TEMPLATE_NAME" bold
    out_pair " TEMPLATE_DIR" "$TEMPLATE_DIR" bold
    out_pair " PROJ_DIR" "$PROJ_DIR" bold
    out_pair " OVERRIDE" "$OVERRIDE\n" bold
    
    # Check if project already exists using given name
    [[ -d "$PROJ_DIR" || -f "${PROJ_DIR}/docker-compose.yml" ]]
    test $? --te "\033[1;33mWARNING:\033[0m Project name '$NAME' already exists."

    # Tell user that they can use --override to override existing project
    [[ $? -eq 0 && $OVERRIDE -eq 1 ]]
    
    test $? --te "If you want to override existing project, run this command again with --override flag to override. Exit." --txit

    # Check if given name is a valid project name
    test __compose_project_name_is_valid "$NAME" --fe "\033[1;31mERROR:\033[0m Invalid project name '$NAME'. Valid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore." --fxit

    # Check if specified template exists
    test file_exists "${TEMPLATE_DIR}/template.yml" --fe "\033[1;31mERROR:\033[0m Template '$TEMPLATE_NAME' not found." --fxit

    echo "Building project from '$TEMPLATE_NAME' template..."

    # Copy template directory
    cp -r $TEMPLATE_DIR $PROJ_DIR

    test $? --fe "\033[1;31mERROR:\033[0m Failed to create project directory by copying template directory." --fxit
    
    # Rename template.yml to docker-compose.yml
    mv "${PROJ_DIR}/template.yml" "${PROJ_DIR}/docker-compose.yml"

    test $? --fe "\033[1;31mERROR:\033[0m Failed to rename project compose file from 'template.yml' to 'docker-compose.yml'." --fxit

    echo "\033[1;32mSUCCESS:\033[0m The project '$NAME' was built successfully!"
}

#####
# Private functions
#####
__compose_project_name_is_valid()
{
    echo "$1" | grep -oP "^\w{1}[\w-_]*"

    return $?
}