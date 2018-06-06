#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ./project.sh

project_ps()
{
    o_bold "NAME\n"
    echo "---"

    while read data; do
        echo "  $data"
    done < <(cut -d= -f1 -s $PROJECT_MAP)
}