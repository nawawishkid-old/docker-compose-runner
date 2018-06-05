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