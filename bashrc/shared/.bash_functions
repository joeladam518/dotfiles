# -*- shell-script -*-
# shellcheck shell=bash
# Global Bash Functions

# Ask a yes or no question
confirm()
{
    local prompt answer response
    prompt="$(cmsg -g "$* ")"
    read -er -t 10 -p "$prompt" answer
    for response in y Y yes Yes YES sure Sure SURE ok Ok OK
    do
        if [ "_$answer" == "_$response" ]; then
            return 0
        fi
    done

    return 1
}

# Creates an archive (*.tar.gz) from given directory.
tarthis()
{
    tar -cvzf "${1%%/}.tar.gz" "${1%%/}/"
    return "$?"
}

# Create a ZIP archive of a file or folder.
zipthis()
{
    zip -r "${1%%/}.zip" "$1"
    return "$?"
}

# Handy Extract function
extract()
{
    if [ ! -f "$1" ]; then
        echo "'${1}' is not a valid file!" 1>&2
        return 1
    fi

    case "$1" in
        *.tar.bz2) tar -xvjf "$1" ;;
        *.tar.gz) tar -xvzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar -x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar -xvf "$1" ;;
        *.tbz2) tar -xvjf "$1" ;;
        *.tgz) tar -xvzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z -x "$1" ;;
        *) echo "'${1}' cannot be extracted via >extract<" 1>&2; return 1 ;;
    esac

    return "$?"
}

# start tmux
tmux()
{
    if [ "$#" -eq 0 ]; then
        command tmux new -s 'jh' -n ''
    else
        command tmux "$@"
    fi
}
