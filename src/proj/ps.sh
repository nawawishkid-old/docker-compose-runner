#!/usr/bin/env bash

# This is not a stand-alone script.
# It's a part of ./proj.sh

# List all projs
proj_ps()
{
    o_bold "  PROJECTS\n"
    echo "  ---"

    while read data; do
        # echo $data | cut -d= -f1 -s
        # echo $data | cut -d= -f2 -s
        echo "  $data"
    done < <(cat $PROJECT_MAP)
}