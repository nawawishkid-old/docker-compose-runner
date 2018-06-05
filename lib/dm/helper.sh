#!/usr/bin/env bash

# Check if argument an integer
# tested: true
is_int()
{
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Check if argument empty
#
# param must not be quoted
# tested: true
empty()
{
    # echo "--- empty() ---"
    # echo "Arg: $#"
    [[ -z "$1" || $# -eq 0 || "$1" = "" ]]
    # [ $# -eq 0 ]
    # echo "Returned: $?"
}

# Check if argument an existing file
# tested: true
file_exists()
{
    [ -f "$1" ]
}

# Check if argument an existing directory
# tested: true
dir_exists()
{
    # echo "1: $1"
    [ -d "$1" ]
}

# Run given function, then response to its returned value by another function and/or string to be echoed.
#
# syntax: test [options] <arguments> [options]
# tested: true
test()
{
    # echo -e "\nTesting..."

    local CMD=""
    local CMD_ARGS=""
    local TRUE_ECHO=""
    local FALSE_ECHO=""
    local TRUE_EXEC=""
    local FALSE_EXEC=""
    local TRUE_EXIT=1
    local FALSE_EXIT=1
    local RETURNED=""

    while [ $# -ne 0 ]; do
        case "$1" in
            --true-echo | --te)
                shift
                TRUE_ECHO="$1"
            ;;
            --false-echo | --fe)
                shift
                FALSE_ECHO="$1"
            ;;
            --true-exec | --txec)
                shift
                TRUE_EXEC="$1"
            ;;
            --false-exec | --fxec)
                shift
                FALSE_EXEC="$1"
            ;;
            --true-exit | --txit)
                TRUE_EXIT=0
            ;;
            --false-exit | --fxit)
                FALSE_EXIT=0
            ;;
            *)
                if [ "$CMD" = "" ]; then
                    CMD="$1"
                else
                    CMD_ARGS="${CMD_ARGS}$1 "
                fi
            ;;
        esac

        shift

    done

    local TYPE=$(type -t "$CMD")

    # echo "Cmd: $CMD"
    # echo "Cmd_args: $CMD_ARGS"
    # echo "Type: $TYPE"

    if [[ $TYPE = "function" || $TYPE = "builtin" ]]; then
        # echo "command: $CMD $CMD_ARGS"

        $CMD $CMD_ARGS

        # echo "---- $?"
        
        RETURNED=$?

    else RETURNED="$CMD"
    fi

    # echo "Returned: $RETURNED"

    if [ "$RETURNED" -eq 0 ]; then
        [ "$TRUE_ECHO" != "" ] && echo -e "$TRUE_ECHO"
        $TRUE_EXEC # run command, if exists
        [ $TRUE_EXIT -eq 0 ] && exit 0
        return 0
    else
        [ "$FALSE_ECHO" != "" ] && echo -e "$FALSE_ECHO"
        $FALSE_EXEC # run command, if exists
        [ $FALSE_EXIT -eq 0 ] && exit 1
        return 1
    fi
}

# Write string with prepended datetime to a file
#
# tested: false
# status: need modifications
log()
{
    local DATE=$(date "+%Y-%m-%d")
    local CUR_FILE="${LOG_DIR}/$(find ${LOG_DIR}/* -maxdepth 1 -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d" " -f2 | grep -oP '(?<=\/)log-.*\.log$')"
    local RESULT="[$DATE $(date "+%H:%M:%S")] \"$1\""
    
    # echo "Log_dir: $LOG_DIR"
    # echo "Cur_file: $CUR_FILE"
    # exit

    if [ ! -f $CUR_FILE ]; then
        echo $RESULT > "${LOG_DIR}/log-${APP_NAME}-${DATE}.log"
        return 0
    fi

    local LINES=$(cat $CUR_FILE | wc -l)

    # echo "Lines: $LINES"

    if [ "$LINES" -ge 1000 ]; then
        # echo "Write new log file."

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
        # echo "Append log file."
        echo $RESULT >> $CUR_FILE
    fi

    return 0
}