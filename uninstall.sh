#!/usr/bin/env bash

set -Eeo pipefail

# Functions
usage() {
    echo "usage: $(basename "${0}") [-h] {system}"
    echo ""
    echo "Uninstall dotfiles on to you machine"
    echo ""
    echo "arguments:"
    echo "  system          The type of system your installing dotfiles on to. (desktop|mac|server)"
    echo ""
    echo "options:"
    echo "  -h              Displays this help message."
}

is_valid_system() {
    echo "desktop mac server" | grep -w -q "$1"
}

parse_options() {
    while :; do
        case "${1-""}" in
            -h | --help)
                usage
                exit 0
                ;;
            -?*)
                echo "Unknown option: ${1}"
                exit 1
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    return 0
}

parse_arguments() {
    system="$1"

    if [ -z "$system" ]; then
        echo "system is required" 1>&2
        exit 1
    fi

    if ! is_valid_system "$system"; then
        echo "Error: Invalid system" 1>&2
        exit 1
    fi

    shift
}

# Variables
DOTFILES_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"
BIN_DIR="${DOTFILES_DIR}/bin"

# Start Script

parse_options "$@"
parse_arguments "$@"

## Check
#echo "DOTFILES_DIR: ${DOTFILES_DIR}"
#echo "REPOS_DIR: ${REPOS_DIR}"
#echo "BIN_DIR: ${BIN_DIR}"
#echo "system: ${system}"
#exit 0

cd "$HOME" || exit 1

# Add the bin dir to path if it's not there
if [[ ! "$PATH" =~ (^|:)"$BIN_DIR"(:|$) ]]; then
    export PATH="${PATH}:${BIN_DIR}"
fi

# Set the rcfile variable (because mac is different from linux)
if [ "$system" == "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

if [ -L "${HOME}/${rcfile}" ]; then
    rm -v "${HOME}/${rcfile}"
fi

# restore the old .bashrc file if it exists
if [ -f "${HOME}/${rcfile}.old" ]; then
    mv "${HOME}/${rcfile}.old" "${HOME}/${rcfile}"
fi

if [ -L "${HOME}/.vim" ]; then
    rm -v "${HOME}/.vim"
fi

if [ -L "${HOME}/.vimrc" ]; then
    rm -v "${HOME}/.vimrc"
fi

if [ -L "${HOME}/.tmux.conf" ]; then
    rm -v "${HOME}/.tmux.conf"
fi

# if server we're done!
if [ "$system" == "server" ]; then
    exit 0
fi

if [ -L "${HOME}/.gitconfig" ]; then
    rm -v "${HOME}/.gitconfig"
fi
