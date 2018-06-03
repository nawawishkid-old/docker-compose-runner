#!/usr/bin/env bash

APP_NAME="dm"
ROOTDIR=${PWD}
MAP_FILE="${ROOTDIR}/conf/compose/map"
LOG_DIR="${ROOTDIR}/log/dm"

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

log()
{
    local DATE=$(date "+%Y-%m-%d")
    local CUR_FILE="${LOG_DIR}/$(find ${LOG_DIR}/* -maxdepth 1 -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d" " -f2 | grep -oP '(?<=\/)log-.*\.log$')"
    local RESULT="[$DATE $(date "+%H:%M:%S")] \"$1\""
    
    echo $LOG_DIR
    echo "Cur_file: $CUR_FILE"
    # exit

    if [ ! -f $CUR_FILE ]; then
        echo $RESULT > "${LOG_DIR}/log-${APP_NAME}-${DATE}.log"
        return 0
    fi

    local LINES=$(cat $CUR_FILE | wc -l)

    echo "Lines: $LINES"

    if [ "$LINES" -ge 1000 ]; then
        echo "Write new log file."

        # Find existing file created today
        local EXISTING_FILE=$(find ${LOG_DIR} -type f -name "*${DATE}*" | wc -l)
        local NEW_FILE="${LOG_DIR}/log-${APP_NAME}-${DATE}"

        # If there is existing file, create a new one with name appended by number of replications
        if [ $EXISTING_FILE -gt 0 ]; then
            echo $RESULT > "${NEW_FILE}-${EXISTING_FILE}.log"
        else
            echo $RESULT > "${NEW_FILE}.log"
        fi
    else
        echo "Append log file."
        echo $RESULT >> $CUR_FILE
    fi

    return 0
}

helper_arg_exists()
{
    if [ "$1" != "" ]; then return 0
    else return 1
    fi
}

helper_test_echo()
{
    # echo
    # echo "--- helper_test_echo ---"
    # echo
    # echo "1: $1"
    # echo "2: $2"
    # echo "3: $3"

    local CMD="$1"
    local CMD_ARGS="$2"
    local EXIT="$3"
    local TRUE_ECHO="TRUE"
    local FALSE_ECHO="FALSE"
    local CALLBACK=""

    # echo "- CMD: ${CMD}"
    # echo "- CMD_ARGS: ${CMD_ARGS[@]}"
    # echo "- Exit: $EXIT"
    # echo "- All before shift 2: $@"
    # echo "- CMD_ARGS[0]: ${#CMD_ARGS[1]}"

    # Avoid first arg which is the arg we need to pass to helper_arg_exists()
    if [[ ${#CMD_ARGS[@]} -eq 0 || "${#CMD_ARGS[0]}" = "" ]]; then
        shift 2
    else
        shift 3
    fi

    # echo "- All after shift 2: $@"
    # echo
    # exit

    # echo "Loop start..."
    while [ $# -ne 0 ]; do
        # echo "  In loop: $1"
        case "$1" in
            --true-echo | --true-echo=*)
                local RESULT=$(echo "$1" | cut -d= -f2 -s)
                if [ "$RESULT" = "" ]; then
                    shift
                    TRUE_ECHO="$1"
                else
                    TRUE_ECHO=$RESULT
                fi
            ;;
            --false-echo | --false-echo=*)
                local RESULT=$(echo "$1" | cut -d= -f2 -s)
                # echo '--- FALSE_ECHO ---'
                if [ "$RESULT" = "" ]; then
                    shift
                    FALSE_ECHO="$1"
                else
                    FALSE_ECHO=$RESULT
                fi
            ;;
            --exec)
                shift
                CALLBACK="$@"
                break
            ;;
            *)
                # Undefined flag becomes the flag of $CMD
                CMD_ARGS+=("$1")
            ;;
        esac

        shift
    done

    # echo "Loop end"
    # echo

    # Make $CMD and $CMD_ARGS becomes valid command
    local STR_ARGS=""

    for i in ${CMD_ARGS[@]}; do
        STR_ARGS="${STR_ARGS} $i"
    done

    # echo "- STR_ARGS: ${STR_ARGS}"
    # echo "- FULL STR_CMD: ${CMD} ${STR_ARGS}"
    
    $CMD $STR_ARGS
    # echo "$CMD $STR_ARGS"
    
    if [ $? -eq 0 ]; then
        # echo "Result: $?"
        # echo "THIS IS TRUE"
        if [ "$TRUE_ECHO" != "" ]; then
            echo $TRUE_ECHO
        fi

        if [ "$EXIT" = "--true-exit" ]; then exit 0
        else return 0
        fi
    else
        # echo "Result: $?"
        # echo "THIS IS FALSE"
        if [ "$FALSE_ECHO" != "" ]; then
            echo $FALSE_ECHO
        fi

        # Callback
        $CALLBACK

        if [ "$EXIT" = "--false-exit" ]; then exit 1
        else return 1
        fi
    fi
}

helper_arg_exists_echo()
{
    local CMD="helper_arg_exists"
    local CMD_ARGS=("$1")
    # echo "1: $1"
    # echo "cmd_args: ${CMD_ARGS[@]}"
    shift
    # echo "all: $@"
    
    helper_test_echo "$CMD" "${CMD_ARGS[@]}" --false-exit "$@"
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
                helper_arg_exists_echo "$1" --false-echo "Missing compose name argument: ${APP_NAME} compose build <compose-name> [[--php <version>] [--mysql <version>] [--no-cache]]" --true-echo=""
                compose_build "$@"
                exit
            ;;
            up )
                shift
                helper_arg_exists_echo "$1" --false-echo "Missing compose name argument: ${APP_NAME} compose up <compose-name>" --true-echo=""
                compose_up "$1"
            ;;
            down )
                shift
                helper_arg_exists_echo "$1" --false-echo="Missing compose name argument: ${APP_NAME} compose down <compose-name>" --true-echo=""
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

compose_get_file_by_project_name()
{
    local NAME="$1"
    local COMPOSED_FILE=$(grep "${NAME}" ${MAP_FILE} | cut -d= -f2)

    echo $COMPOSED_FILE
}

compose_get_file_by_name()
{
    if [ "$1" = "" ]
    then
        echo "dm compose up|down <compose-name> required 1 argument."
        exit
    fi

    local NAME="$1"
    local COMPOSED_FILE=$(compose_get_file_by_project_name "$NAME")

    if [ "$COMPOSED_FILE" = "" ]
    then
        echo "Compose file of ${NAME} not found."
        exit
    fi

    if [ ! -f $COMPOSED_FILE ]
    then
        echo "${COMPOSED_FILE} is not a compose file."
        exit
    fi

    echo $COMPOSED_FILE

    # echo 'Running docker-compose up...'
}

compose_project_file_exists()
{
    # echo '--- compose_project_file_exists ---'
    # echo "File: $1"
    if [ -f "$1" ]; then
        # echo "EXISTS"
        return 0
    else 
        # echo "NOT EXISTS"
        return 1
    fi
}

compose_project_dir_exists()
{
    # echo '--- compose_project_file_exists ---'
    # echo "File: $1"
    if [ -d "$1" ]; then
        # echo "EXISTS"
        return 0
    else 
        # echo "NOT EXISTS"
        return 1
    fi
}

compose_project_file_exists_echo()
{
    # echo "--- compose_project_file_exists_echo ---"
    local ARGS=("$1")
    # echo "${ARGS[@]}"

    helper_test_echo "compose_project_file_exists" "$ARGS" --false-exit "$@"
}

compose_project_dir_exists_echo()
{
    local ARGS=("$1")

    helper_test_echo "compose_project_dir_exists" "$ARGS" --false-exit "$@"
}

compose_project_name_exists()
{
    local PROJ_NAME="$1"
    # echo "Project name: $1"
    cut -d= -f1 -s "$MAP_FILE" | grep -o "$PROJ_NAME"

    return $?
}

compose_project_name_valid()
{
    echo "$1" | grep -oP "^\w{1}[\w-_]*"

    return $?
}

compose_project_name_exists_echo()
{
    # echo "--- compose_project_file_exists_echo ---"
    # echo "1: $1"
    local ARGS=("$1")
    # echo "Args: ${ARGS[@]}"

    helper_test_echo "compose_project_name_exists" "$ARGS" --no-exit "$@"
}

compose_down()
{
    # echo
    # echo "--- compose_down ---"
    # echo
    # helper_arg_exists_echo "$1" "compose_down <compose-name> required!"
    # echo "1: $1"
    local COMPOSED_FILE=$(compose_get_file_by_project_name "$1")
    # echo $COMPOSED_FILE
    # exit

    compose_project_file_exists_echo "$COMPOSED_FILE" --false-echo "Compose file of '$1' project does not exists." --true-echo ""

    echo "Composed file: '$COMPOSED_FILE'"

    # if [  ]
    local COMPOSED_FILE_DIR=$(echo $COMPOSED_FILE | grep -oP ".*(?=\/.*\.yml$)")

    echo "Composed file dir: '$COMPOSED_FILE_DIR'"

    compose_project_dir_exists_echo "$COMPOSED_FILE_DIR" --false-echo "Directory of compose project '$1' does not exist." --true-echo ""

    cd $COMPOSED_FILE_DIR
    echo "Current dir: '$(pwd)'"
    docker-compose down
}

compose_up()
{
    local COMPOSED_FILE=$(compose_get_file_by_name "$1")

    docker-compose -f $COMPOSED_FILE up -d

    if [ $? -eq 0 ]; then echo "docker-compose up success!"
    else echo 'docker-compose up failed!'
    fi
}

compose_build()
{
    local PHP_V="7.2"
    local MYSQL_V="5.7"
    local FLAG_NO_CACHE=0
    local NAME="$1"
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
            --no-cache )
                FLAG_NO_CACHE=1
            ;;
            --override )
                OVERRIDE=1
            ;;
        esac
        
        shift

    done

    echo "Checking compose project name '$NAME'..."
    
    compose_project_name_exists_echo "$NAME" --true-echo "Compose project name '$NAME' already exists." --false-echo "Building compose file..."

    if [[ $? -eq 0 && $OVERRIDE -eq 0 ]]; then
        echo "If you want to override existing project, run this command again with --override flag to override. Exit."
        exit
    elif [[ $? -eq 0 && $OVERRIDE -eq 1 ]]; then
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
    local COMPOSE_DIR="${ROOTDIR}/conf/compose"
    local COMPOSE_OWN_DIR="${COMPOSE_DIR}/${NAME}-php${PHP_V}-mysql${MYSQL_V}"
    local COMPOSED_FILE=${COMPOSE_OWN_DIR}/docker-compose.yml

    if [[ ! -f $COMPOSED_FILE || $FLAG_NO_CACHE -eq 1 ]]
    then
        echo "Creating the compose file directory..."

        mkdir $COMPOSE_OWN_DIR

        echo 'Writing the compose file...'

        cat $COMPOSE_TEMPLATE \
        | sed "s,{root_dir},$ROOTDIR,g; s,{db},mysql,g; s,{db_version},$MYSQL_V,g; s,{php_version},$PHP_V,g;" \
        > $COMPOSED_FILE

        compose_build_mapping $NAME $COMPOSED_FILE
    elif [[ -f $COMPOSED_FILE && $FLAG_NO_CACHE -eq 0 ]]
    then
        echo "This spec has already composed"
        exit
    fi
}

# Check if compose name=path already mapped
compose_build_mapping()
{
    local NAME="$1"
    local COMPOSED_FILE="$2"
    local MAPPED="$NAME=$COMPOSED_FILE"

    echo 'Check map file...'
    echo $MAPPED

    if [ ! -f $MAP_FILE ]
    then
        echo "Error: $MAP_FILE file not found."
        exit
    fi

    local GREP=$(grep $MAPPED $MAP_FILE)

    if [ "$GREP" = "" ]
    then
        echo "No map, mapping name-path of compose file..."
        printf "$MAPPED\n" >> $MAP_FILE
    else
        echo "Compose name-path already mapped."
    fi
}

test_pipe()
{
    while read data; do
        echo "I'm just echoing data: $data"
    done
}

test_boolean()
{
    if [ "$1" = "true" ]; then return 0
    else return 1
    fi
}

test_boolean_echo()
{
    test_boolean "$1"

    if [ $? -eq 0 ]; then echo 'TRUE!!!'
    else echo 'FALSE!!!'
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
        test )
            shift
            test_boolean_echo "$1"
            # echo "$1" | test_pipe | test_pipe | test_pipe
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
