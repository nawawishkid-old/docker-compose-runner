#!/usr/bin/env bash

echo "Downloading wp-cli.phar..."

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info

if [ $? -eq 0 ]; then
    echo 'Download success!'
else
    echo "Failed to load wp-cli.phar from https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
fi

echo "Making wp-cli.phar executable as wp..."
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp --info

if [ $? -eq 0 ]; then
    echo 'Success! wp-cli is now ready to use!'
else
    echo "Failed to make wp-cli.phar as 'wp' command by moving it to /usr/local/bin directory."
fi