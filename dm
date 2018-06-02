#!/usr/bin/env bash

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
                compose_build "$@"
                exit
            ;;
            up )
                shift
                compose_up "$1"
            ;;
            down )
                shift
                $(docker-compose down)
            ;;
            help | --help )
                help_compose
                exit
            ;;
        esac
        
        shift

    done
}

compose_up()
{
    local NAME="$1"
    local COMPOSED_FILE=$(grep "${NAME}" ${MAP_FILE} | cut -d= -f2)

    echo $COMPOSED_FILE

    if [ $COMPOSED_FILE = "" ]
    then
        echo "Compose file not found."
        exit
    fi

    if [ ! -f $COMPOSED_FILE ]
    then
        echo "${COMPOSED_FILE} is not a compose file."
        exit
    fi

    echo 'Running docker-compose up...'

    docker-compose -f $COMPOSED_FILE up -d
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
    local COMPOSE_LOCATION="${ROOTDIR}/conf/compose"
    local COMPOSED_FILE=${COMPOSE_LOCATION}/compose-php${PHP_V}-mysql${MYSQL_V}.yml

    if [ -f $COMPOSE_TEMPLATE ]
    then
        echo "ERROR: template of docker-compose.yml: $COMPOSE_TEMPLATE not found!"
        exit
    fi

    if [[ ! -f $COMPOSED_FILE || $FLAG_NO_CACHE -eq 1 ]]
    then
        echo "Writing new compose file..."

        cat $COMPOSE_TEMPLATE \
        | sed "s/{root_dir}/$ROOTDIR/g; s/{db}/mysql/g; s/{db_version}/$MYSQL_V/g; s/{php_version}/$PHP_V/g;" \
        > $COMPOSED_FILE

        echo "Mapping name-path of compose file..."
        echo "$NAME=$COMPOSED_FILE" >> $MAP_FILE
    elif [[ -f $COMPOSED_FILE && $FLAG_NO_CACHE -eq 0 ]]
    then
        echo "This spec has already composed"
        exit
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
