#!/usr/bin/env bash

source ./helper.sh

APP_NAME="dm"
ROOTDIR=${PWD}
MAP_FILE="${ROOTDIR}/conf/compose/map"
LOG_DIR="${ROOTDIR}/log/dm"
COMPOSE_DIR="${ROOTDIR}/conf/compose"
COMPOSE_PROJECTS_DIR="${COMPOSE_DIR}/projects"
COMPOSE_TEMPLATE_DIR="${COMPOSE_DIR}/template"

verbose()
{
    local VERBOSE=0
    local TEXT=""

    while [ $# -ne 0 ]; do
        case "$1" in
            -v | --verbose)
                VERBOSE=1
                shift
            ;;
            *)
                TEXT="${TEXT}${1}"
                shift
            ;;
        esac
    done

    if [ $VERBOSE -eq 1 ]; then
        echo "$TEXT"
    fi
}

help_all()
{
    echo 'dm (Docker Manager)'
    echo ''
    echo 'COMMAND:'
    echo ''
    echo '  run                   Run container.'
    echo '  compose               docker-compose related command.'
    echo '  help | --help         This help text.'
    echo ''
}

help_compose()
{
    echo 'dm compose'
    echo ''
    echo 'COMMAND:'
    echo ''
    echo '  build                 Build docker-compose.yml file'
    echo '  up                    docker-compose up'
    echo '  down                  docker-compose down'
    echo ''
}

help_run()
{
    echo 'dm compose'
    echo ''
    echo 'COMMAND:'
    echo ''
    echo ''
}

if [ "$1" = "" ]
then
    help
    exit
fi

run()
{
    case "$1" in
        help | --help )
            help_run
            exit
        ;;
        apache )
            TARGET="
                -d \
                -v ${ROOTDIR}/www:/var/www \
                -v ${ROOTDIR}/docker/apache2/sites-available:/etc/apache2/sites-available \
                -p 80:80 \
                nawawishkid/wpth:apache-latest
            "
            echo 'Running apache...'
        ;;
        # php-fpm )
        #     TARGET="
        #         -d \
        #         -v ${ROOTDIR}/www:/var/www \
        #         --link
        #     "
        # ;;
        *)
            
        ;;
    esac
    
    docker run $TARGET
}

compose()
{

    while [ "$1" != "" ]
    do
        case "$1" in
            build )
                shift
                test empty $1 --te "Missing compose project name argument: ${APP_NAME} compose build <project-name> [[--php <version>] [--mysql <version>] [--no-cache]]"

                compose_build "$@"
                exit
            ;;
            delete)
                shift
                test empty $1 --te "Missing compose project name argument: ${APP_NAME} compose delete <project-name>" --txit
                
                compose_delete "$@"
                exit
            ;;
            ls)
                compose_ls
                exit
            ;;
            up )
                shift
                test empty $1 --te "Missing compose project name argument: ${APP_NAME} compose up <project-name>" --txit
                
                compose_up "$1"
            ;;
            down )
                shift
                test empty $1 --te "Missing compose project name argument: ${APP_NAME} compose down <project-name>" --txit
                
                compose_down "$1"
            ;;
            help | --help )
                help_compose
                exit
            ;;
        esac
        
        shift

    done
}

compose_get_project_dir_by_name()
{
    local NAME="$1"
    local PROJ_DIR=$(grep "${NAME}" ${MAP_FILE} | cut -d= -f2 | head -n 1)

    echo ${PROJ_DIR}
}

compose_get_project_file_by_name()
{
    echo "$(compose_get_project_dir_by_name "$1")/docker-compose.yml"
}

compose_project_name_exists()
{
    local PROJ_NAME="$1"
    # echo "Project name: $1"
    cut -d= -f1 -s "$MAP_FILE" | grep -o "^$PROJ_NAME$"

    return $?
}

compose_project_name_valid()
{
    echo "$1" | grep -oP "^\w{1}[\w-_]*"

    return $?
}

compose_ls()
{
    echo "Compose projects:"
    echo
    echo "  Name    "
    echo "=========="
    while read proj; do
        echo "  $proj"
    done < <(cut -d= -f1 "${COMPOSE_DIR}/map")
}

compose_get_project_mapping_by_name()
{
    local NAME="$1"
    local MAPPED_DATA=$(grep "^${NAME}=" ${MAP_FILE})

    echo ${MAPPED_DATA}
}

compose_get_template()
{
    local NAME="$1"
    
    echo $(find $COMPOSE_TEMPLATE_DIR -type f -name "${NAME}.template.yml" -printf "%f\n" | grep -oP '^.*(?=\.template\.yml$')
}

compose_delete()
{
    local NAME="$1"
    local PROJ_DIR=$(compose_get_project_dir_by_name "$NAME")
    local PROJ_FILE=$(compose_get_project_file_by_name "$NAME")
    local PROJ_MAP=$(compose_get_project_mapping_by_name "$NAME")

    # echo "Proj_file: $PROJ_FILE"
    # echo "Proj_dir: $PROJ_DIR"

    log "compose_delete $NAME..."

    test dir_exists "$PROJ_DIR" --fe "\033[1;31mERROR:\033[0m Project directory of '$NAME' does not exists." --te "Project directory of '$NAME' exists."

    if [ $? -eq 0 ]; then
        echo "Removing project directory..."
        # Remove project directory
        rm -r $PROJ_DIR

        if [ $? -eq 0 ]; then
            echo "Removed project directory of '$NAME'"
            log "compose_delete 'Removed project directory of '$NAME'"
        else
            echo "Failed to remove project directory of '$NAME'"
            log "compose_delete 'Failed to remove project directory of '$NAME''"
        fi
    fi

    test file_exists "$PROJ_FILE" --fe "\033[1;31mERROR:\033[0m File of project '$NAME' does not exists." --te "File of project '$NAME' exists." --fxit

    test empty $PROJ_MAP --te "\033[1;31mERROR:\033[0m Map data of project '$NAME' does not exists." --fe "Map data of project '$NAME' exists." --txit

    echo "Unmapping project file..."
    # echo "Map_data: ,${NAME}=${PROJ_DIR},d"
    
    # Remove line from map file
    sed -i "\,${NAME}=${PROJ_DIR},d" $MAP_FILE

    if [ $? -eq 0 ]; then
        echo "Unmapped project file of '$NAME'"
        log "compose_delete 'Unmapped project file of '$NAME''"
    else
        echo "Failed to unmap project file of '$NAME'."
        log "compose_delete 'Failed to unmap project file of '$NAME'.'"
    fi
}

compose_down()
{
    # echo
    # echo "--- compose_down ---"
    # echo
    # echo "1: $1"
    local COMPOSED_FILE=$(compose_get_project_file_by_name "$1")
    # echo $COMPOSED_FILE
    # exit

    test file_exists "$COMPOSED_FILE" --fe "\033[1;31mERROR:\033[0m Compose file of '$1' project does not exists." --fxit

    # echo "Composed file: '$COMPOSED_FILE'"

    local COMPOSED_FILE_DIR=$(echo $COMPOSED_FILE | grep -oP ".*(?=\/.*\.yml$)")

    # echo "Composed file dir: '$COMPOSED_FILE_DIR'"

    test dir_exists "$COMPOSED_FILE_DIR" --fe "\033[1;31mERROR:\033[0m Directory of compose project '$1' does not exist." --fxit

    cd $COMPOSED_FILE_DIR
    # echo "Current dir: '$(pwd)'"
    docker-compose down
}

compose_up()
{
    local COMPOSED_FILE=$(compose_get_project_file_by_name "$1")

    docker-compose -f $COMPOSED_FILE up -d

    if [ $? -eq 0 ]; then echo "docker-compose up successfully!"
    else echo 'docker-compose up failed!'
    fi
}

compose_build()
{
    local PHP_V="7.2"
    local MYSQL_V="5.7"
    local NAME="$1"
    local TEMPLATE="default"
    local OVERRIDE=0

    if ( ! compose_project_name_valid "$NAME" ); then
        echo "Invalid project name '$NAME'. Valid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore."
        log "Invalid project name '$NAME'. Valid name must begins with either character or number, not punctuation, for first character. After that the name can also contains dash and underscore."
        exit
    fi

    shift

    while [ $# -ne 0 ]
    do
        case "$1" in
            --php )
                shift
                PHP_V="$1"
            ;;
            --mysql )
                shift
                MYSQL_V="$1"
            ;;
            --override )
                OVERRIDE=1
            ;;
            --template)
                shift
                TEMPLATE="$1"
            ;;
        esac
        
        shift

    done

    echo "Checking compose project name '$NAME'..."
    
    test compose_project_name_exists "$NAME" --te "Compose project name '$NAME' already exists." --fe "Building compose file..."

    if [[ $? -eq 0 && $OVERRIDE -eq 0 ]]; then
        echo "If you want to override existing project, run this command again with --override flag to override. Exit."
        exit
    elif [[ $? -eq 1 && $OVERRIDE -eq 1 ]]; then
        echo "Overriding project '$NAME'..."
    fi

    if [ "$PHP_V" = "" ]; then
        echo "Missing php version, --php <version> is required."
        exit
    elif [[ "$PHP_V" != "7.0" && "$PHP_V" != "7.1" && "$PHP_V" != "7.2" ]]
    then
        echo "PHP${PHP_V} is not supported. Supported versions are 7.0, 7.1, and 7.2"
        exit
    fi

    if [ $MYSQL_V = "" ]; then
        echo "Missing mysql version, --mysql <version> is required."
        exit
    elif [[ $MYSQL_V != "8.0" && $MYSQL_V != "5.7" && $MYSQL_V != "5.6" ]]
    then
        echo "MySQL${MYSQL_V} is not supported. Supported versions are 5.6, 5.7, and 8.0"
        exit
    fi

    local COMPOSE_TEMPLATE="${ROOTDIR}/conf/compose/template/compose-template.yml"
    local COMPOSE_OWN_DIR="${COMPOSE_PROJECTS_DIR}/${NAME}-php${PHP_V}-mysql${MYSQL_V}"
    local COMPOSED_FILE=${COMPOSE_OWN_DIR}/docker-compose.yml

    if [[ ! -f $COMPOSED_FILE || $OVERRIDE -eq 1 ]]
    then

        if [ $OVERRIDE -eq 1 ]; then
            echo "Removing existing project..."
            compose_delete "$NAME"
        fi

        echo "Creating the compose file directory..."

        mkdir $COMPOSE_OWN_DIR

        echo 'Writing the compose file...'

        cat $COMPOSE_TEMPLATE \
        | sed "s,{root_dir},$ROOTDIR,g; s,{db},mysql,g; s,{db_version},$MYSQL_V,g; s,{php_version},$PHP_V,g;" \
        > $COMPOSED_FILE

        compose_build_mapping $NAME $COMPOSE_OWN_DIR

        echo "Project built successfully!"
    elif [[ -f $COMPOSED_FILE && $OVERRIDE -eq 0 ]]
    then
        echo "This project has already built"
        exit
    fi
}

# Check if compose name=path already mapped
compose_build_mapping()
{
    local NAME="$1"
    local COMPOSE_OWN_DIR="$2"
    local MAPPED="$NAME=$COMPOSE_OWN_DIR"

    echo 'Check map file...'
    echo $MAPPED

    if [ ! -f $MAP_FILE ]
    then
        echo -e "\033[1;31mERROR:\033[0m $MAP_FILE file not found."
        exit
    fi

    echo "Mapping..."

    local GREP=$(grep $MAPPED $MAP_FILE)

    if [ "$GREP" = "" ]
    then
        printf "$MAPPED\n" >> $MAP_FILE
        echo "Mapping successful!"
    else
        echo "Project name-location already mapped."
    fi
}

while [ "$1" != "" ] 
do
    case "$1" in
        run )
            shift
            run "$1"
        ;;
        compose )
            shift
            compose "$@"
            exit
        ;;
        help | --help )
            help_all
            exit
        ;;
        *)
            help_all
            exit
        ;;
    esac
    
    shift

done
