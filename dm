#!/usr/bin/env bash

run()
{
    case "$1" in
        apache )
            TARGET="
                -d \
                -v ${PWD}/www:/var/www \
                -v ${PWD}/docker/apache2/sites-available:/etc/apache2/sites-available \
                -p 80:80 \
                nawawishkid/wpth:apache-latest
            "
            echo 'Running apache...'
        ;;
        php-fpm )
            TARGET="
                -d \
                -v ${PWD}/www:/var/www \
                --link
            "
        ;;
        *)
            
        ;;
    esac
    
    docker run $TARGET
}

write_compose()
{
    echo 'Composing...'

    local PHP_V="7.2"
    local MYSQL_V="5.7"

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
        esac
        
        shift

    done

    if [ $PHP_V = "" ]; then
        echo "Missing php version, --php <version> is required."
        exit
    elif [[ $PHP_V != "7.0" && $PHP_V != "7.1" && $PHP_V != "7.2" ]]
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

    COMPOSE_TEMPLATE="./conf/compose/compose-template.yml"

    if [ -f $COMPOSE_TEMPLATE ]
    then
        cat $COMPOSE_TEMPLATE \
        | sed 's/{db}/mysql/g; s/{db_version}/$MYSQL_V/g; s/{php_version}/$PHP_V/g;' \
        > compose-php${PHP_V}-mysql${MYSQL_V}.yml
    else
        echo 'ERROR: template of docker-compose.yml: $COMPOSE_TEMPLATE not found!'
    fi
}

compose()
{
    local COMPOSE_FILE="$1"
    if [[ $COMPOSE_FILE = "" || ! -f $COMPOSE_FILE ]]
    then
        echo "Compose file not found."
    fi

    docker-compose -f $COMPOSE_FILE up -d
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
            write_compose "$@"
        ;;
        *) echo default
        ;;
    esac
    
    shift

done
