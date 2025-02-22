# -*- shell-script -*-
# shellcheck shell=bash
# Shared functions

confirm()
{
    # Ask a yes or no question

    local CONFIRM_PROMPT CONFIRM_ANSWER CONFIRM_RESPONSE

    CONFIRM_PROMPT="$(cmsg -g "$* ")"
    read -er -t 10 -p "$CONFIRM_PROMPT" CONFIRM_ANSWER

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
    # Create a ZIP archive of a file or folder

    zip -r "${1%%/}.zip" "$1"
    return "$?"
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

