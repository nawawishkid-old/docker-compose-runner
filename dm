#!/usr/bin/env bash

APP_NAME="dm"

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

helper_arg_exists()
{
    if [ "$1" != "" ]; then return 0
    else return 1
    fi
}

helper_test_echo()
{
    echo
    echo "--- helper_test_echo ---"
    echo
    echo "1: $1"
    echo "2: $2"
    echo "3: $3"

    local CMD="$1"
    local CMD_ARGS="$2"
    local TRUE_ECHO="TRUE"
    local FALSE_ECHO="FALSE"
    local CALLBACK=""

    # Avoid first arg which is the arg we need to pass to helper_arg_exists()
    echo "- CMD: ${CMD}"
    echo "- CMD_ARGS: ${CMD_ARGS[@]}"
    echo "- All before shift 2: $@"
    echo "- CMD_ARGS[0]: ${#CMD_ARGS[1]}"

    if [[ ${#CMD_ARGS[@]} -eq 0 || "${#CMD_ARGS[0]}" = "" ]]; then
        shift
    else
        shift 2
    fi

    echo "- All after shift 2: $@"
    echo
    # exit

    echo "Loop start..."
    while [ $# -ne 0 ]; do
        echo "  In loop: $1"
        case "$1" in
            --true-echo)
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
                echo '--- FALSE_ECHO ---'
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

    echo "Loop end"
    echo

    # Make $CMD and $CMD_ARGS becomes valid command
    local STR_ARGS=""

    for i in ${CMD_ARGS[@]}; do
        STR_ARGS="${STR_ARGS} $i"
    done

    echo "- STR_ARGS: ${STR_ARGS}"
    echo "- FULL STR_CMD: ${CMD} ${STR_ARGS}"
    
    $CMD $STR_ARGS
    
    if [ $? -eq 0 ]; then
        echo $TRUE_ECHO
        return 0
    else
        echo $FALSE_ECHO

        # Callback
        $CALLBACK
        exit 1
    fi
}

helper_arg_exists_echo()
{
    local CMD="helper_arg_exists"
    local CMD_ARGS=("$1")
    echo "1: $1"
    echo "cmd_args: ${CMD_ARGS[@]}"
    shift
    echo "all: $@"
    
    helper_test_echo "$CMD" "${CMD_ARGS[@]}" "$@"
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

ROOTDIR=${PWD}
MAP_FILE="${ROOTDIR}/conf/compose/map"

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
                helper_arg_exists_echo "$1" --false-echo "Missing compose name argument: ${APP_NAME} compose build <compose-name> [[--php <version>] [--mysql <version>] [--no-cache]]"
                compose_build "$@"
                exit
            ;;
            up )
                shift
                helper_arg_exists_echo "$1" --false-echo "Missing compose name argument: ${APP_NAME} compose up <compose-name>"
                compose_up "$1"
            ;;
            down )
                shift
                helper_arg_exists_echo "$1" --false-echo="Missing compose name argument: ${APP_NAME} compose down <compose-name>" --exec echo 'hahaha'
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

compose_get_file_by_name()
{
    if [ "$1" = "" ]
    then
        echo "dm compose up|down <compose-name> required 1 argument."
        exit
    fi

    local NAME="$1"
    local COMPOSED_FILE=$(compose_get_file_from_map_by_name "$NAME")

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

compose_file_exists()
{
    echo '--- compose_file_exists ---'
    echo "$1"
    if [ -f "$1" ]; then return 0
    else return 1
    fi
}

compose_file_exists_echo()
{
    echo "--- compose_file_exists_echo ---"
    local ARGS=("$1")
    echo "${ARGS[@]}"

    helper_test_echo "compose_file_exists" "$ARGS" "$@"

    # : ${2:-"Compose file not exists!"}
    # local ECHO="$2"

    # compose_file_exists "$1"

    # if [ $? -eq 0 ]; then return 0
    # else
    #     echo $ECHO
    #     exit
    # fi
}

compose_down()
{
    echo
    echo "--- compose_down ---"
    echo
    # helper_arg_exists_echo "$1" "compose_down <compose-name> required!"
    echo "1: $1"
    local COMPOSED_FILE=$(compose_get_file_from_map_by_name "$1")
    echo $COMPOSED_FILE
    # exit

    compose_file_exists_echo "$COMPOSED_FILE" --false-echo "HELLO!"
    # exit
    echo 'aaaaaaaaaaaa'

    # if [  ]
    local COMPOSED_FILE_DIR=$(echo $COMPOSED_FILE | grep -o "\w*$")

    cd $COMPOSED_FILE_DIR
    pwd
    # docker-compose down
}

compose_up()
{
    local COMPOSED_FILE=$(compose_get_file_by_name "$1")

    docker-compose -f $COMPOSED_FILE up -d
}

compose_get_file_from_map_by_name()
{
    local NAME="$1"
    local COMPOSED_FILE=$(grep "${NAME}" ${MAP_FILE} | cut -d= -f2)

    echo $COMPOSED_FILE
}

compose_build()
{
    echo 'Building compose file...'

    local PHP_V="7.2"
    local MYSQL_V="5.7"
    local FLAG_NO_CACHE=0
    local NAME="$1"

    shift

    while [ "$1" != "" ]
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
        esac
        
        shift

    done

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
        echo "Writing new compose file..."

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
