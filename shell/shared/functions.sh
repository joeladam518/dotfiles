# -*- shell-script -*-
# shellcheck shell=bash
# Shared functions — sourced by both bash and zsh

confirm()
{
    # Ask a yes or no question

    local CONFIRM_PROMPT CONFIRM_ANSWER CONFIRM_RESPONSE

    CONFIRM_PROMPT="$(cmsg -g "$* ")"

    if [ -n "$ZSH_VERSION" ]; then
        # zsh read syntax: read -r -t TIMEOUT "VARNAME?PROMPT"
        read -r -t 10 "CONFIRM_ANSWER?${CONFIRM_PROMPT}"
    else
        read -er -t 10 -p "$CONFIRM_PROMPT" CONFIRM_ANSWER
    fi

    for CONFIRM_RESPONSE in y Y yes Yes YES sure Sure SURE ok Ok OK
    do
        if [ "_${CONFIRM_ANSWER}" == "_${CONFIRM_RESPONSE}" ]; then
            return 0
        fi
    done

    return 1
}

extract()
{
    # Handy Extract function

    local FILE_PATH
    FILE_PATH="${1:-""}"

    if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
        echo "'${FILE_PATH}' is not a valid file!" 1>&2
        return 1
    fi

    case "$FILE_PATH" in
        *.tar.bz2) tar -xvjf "$FILE_PATH" ;;
        *.tar.gz) tar -xvzf "$FILE_PATH" ;;
        *.bz2) bunzip2 "$FILE_PATH" ;;
        *.rar) unrar -x "$FILE_PATH" ;;
        *.gz) gunzip "$FILE_PATH" ;;
        *.tar) tar -xvf "$FILE_PATH" ;;
        *.tbz2) tar -xvjf "$FILE_PATH" ;;
        *.tgz) tar -xvzf "$FILE_PATH" ;;
        *.zip) unzip "$FILE_PATH" ;;
        *.Z) uncompress "$FILE_PATH" ;;
        *.7z) 7z -x "$FILE_PATH" ;;
        *) echo "'${FILE_PATH}' cannot be extracted via >extract<" 1>&2; return 1 ;;
    esac

    return "$?"
}

tarthis()
{
    # Creates an archive (*.tar.gz) from given directory

    tar -cvzf "${1%%/}.tar.gz" "${1%%/}/"
    return "$?"
}

tmux()
{
    # Fill in the most common arguments I use when starting tmux if I don't
    # provide any specific args.

    if [ "$#" -eq 0 ]; then
        command tmux new -A -s 'jh' -n ''
    else
        command tmux "$@"
    fi
}

zipthis()
{
    local CWD INPUT_PATH DIR_NAME PARENT_DIR PATH_TO_DIR RESULT

    CWD="$(pwd -P)"
    INPUT_PATH="${1:-""}"

    # ensure the user provided a path to zip
    if [ -z "$INPUT_PATH" ]; then
        echo "Usage: zipthis <path-to-dir>"
        return 1
    fi

    # ensure the provided path is readable
    if [ ! -r "$INPUT_PATH" ]; then
        echo "Not readable" 1>&2
        return 1
    fi

    # if its a single file, zip it and return the result
    if [ -f "$INPUT_PATH" ]; then
        zip -r "${1%%/}.zip" "$1"
        RESULT=$?
        cd "$CWD" || return 1
        return "$RESULT"
    fi

    # if its a directory, zip it. By default the directory itself is included so
    # that extracting produces the directory. Pass --contents to zip only the
    # contents without the enclosing directory.
    if [ -d "$INPUT_PATH" ]; then
        DIR_NAME="$(basename "$INPUT_PATH")"
        PARENT_DIR="$(cd "$(dirname "$INPUT_PATH")" > /dev/null 2>&1 && pwd -P)"
        PATH_TO_DIR="${PARENT_DIR%%/}/${DIR_NAME%%/}"

        if [ -z "$PATH_TO_DIR" ] || [ ! -d "$PATH_TO_DIR" ]; then
            echo "Usage: zipthis <path> [--contents]"
            return 1
        fi

        if [ "${2:-}" = "--contents" ]; then
            cd "$PATH_TO_DIR" || return 1
            zip -r "${CWD}/${DIR_NAME}.zip" .
        else
            cd "$PARENT_DIR" || return 1
            zip -r "${CWD}/${DIR_NAME}.zip" "${DIR_NAME}"
        fi

        RESULT=$?
        cd "$CWD" || return 1
        return "$RESULT"
    fi

    # if we get here, the provided path is not a file or directory, so we can't zip it
    echo "Error: can not zip \"$INPUT_PATH\" it's not a file or directory" 1>&2
    return 1
}

printcsv()
{
    local has_headers="0"
    local csv_path="$1"
    shift

    if [ "$1" == "--headers" ]; then
        has_headers="1"
        shift
    fi

    if [ "$has_headers" == "1" ]; then
        tail -n+2 "$csv_path" | column -t -s "," -N "$(head -n 1 "$csv_path")" "$@"
    else
        column -s, -t "$@" < "$csv_path"
    fi
}
