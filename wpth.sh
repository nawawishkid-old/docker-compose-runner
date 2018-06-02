#!/usr/bin/env bash

help()
{
    echo 'This is helptext.'
    exit
}

if [ "$1" = '' ]; then
    help
fi

init()
{
    if [[ $EUID > 0 ]]; then
        echo 'You MUST logged in as root to use this command!'
        exit
    fi

    echo 'This command will install wp-cli and make ./wpth executable as a Linux command'
    echo 'Initializing wpth...'

    # Check if user 'wpth' exists
    echo "Checking 'wpth' user..."
    id -u wpth > /dev/null

    if [ $? -ne 0 ]; then
        echo "User 'wpth' not found, creating user 'wpth'..."
        useradd -mU wpth
        echo wpth:wpth9999 | chpasswd

        if [ $? -eq 0 ]; then
            echo "User 'wpth' created."
        else
            echo "Failed to create 'wpth' user."
        fi

        # Change /home/wpth directory permission
        chmod 700 /home/wpth 
        
        usermod -aG sudo wpth

        if [ $? -eq 0 ]; then
            echo "User 'wpth' added to 'sudo' group."
        else
            echo "Failed to add 'wpth' user to 'sudo' group."
        fi
    else
        echo "User 'wpth' already exists."
    fi

    # Check if 'wp' exists
    echo "Checking 'wp' command (wp-cli)..."
    command -v wp > /dev/null

    if [ $? -ne 0 ]; then
        # Load wp-cli
        echo "wp not found, downloading wp-cli.phar..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        php wp-cli.phar --info
        
        if [ $? -eq 0 ]; then
            echo 'Download success!'
        else
            echo "Failed to load wp-cli.phar from https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
        fi

        echo "Making wp-cli.phar executable as wp..."
        chmod +x wp-cli.phar
        chown wpth:wpth wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        wp --info
        
        if [ $? -eq 0 ]; then
            echo 'Success! wp-cli is now ready to use!'
        else
            echo "Failed to make wp-cli.phar as 'wp' command by moving it to /usr/local/bin directory."
        fi
    else
        echo "wp-cli already installed and ready to use."
    fi

    # Check if wpth command exists
    command -v wpth > /dev/null

    if [ $? -ne 0 ]; then
        # Make wpth executable
        echo 'Making wpth executable...'
        chown wpth:wpth ./wpth.sh
        chmod +x ./wpth.sh
        mv ./wpth.sh /usr/local/bin/wpth

        if [ $? -eq 0 ]; then
            wpth
            echo 'Success!'
        else
            echo 'Failed to make wpth command'
        fi
    else
        echo "command 'wpth' already exists."
    fi
}

# New wordpress website
new()
{
    docker-compose exec php-fpm wp
}

while [ "$1" != '' ] 
do
    case "$1" in
        new )
            shift
            
        ;;
        init )
            shift
            init
        ;;
        --help | help )
            help
        ;;
        *)

        ;;
    esac

    shift
    
done
