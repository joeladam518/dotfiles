#!/usr/bin/env bash

set -Eeo pipefail

# Functions
usage() {
    echo "usage: $(basename "${0}") [-h] {system}"
    echo ""
    echo "Install dotfiles on to your machine"
    echo ""
    echo "arguments:"
    echo "  system          The type of system you're installing dotfiles on to. (desktop|mac|server)"
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
REPOS_DIR="$(dirname "$DOTFILES_DIR")"
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

# Create the repos directory if it doesn't exist
if [ ! -d "$REPOS_DIR" ]; then
    mkdir -p "$REPOS_DIR"
fi

# Set the rcfile variable (because mac is different from linux)
if [ "$system" == "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

# Keep the old bashrc file
if [ -f "${HOME}/${rcfile}" ] && [ ! -L "${HOME}/${rcfile}" ]; then
    if [ -f "${HOME}/${rcfile}.old" ]; then
        echo "Found existing ${rcfile}.old file" 1>&2
        exit 1
    else
        cd "$HOME" && mv "$rcfile" "${rcfile}.old"
    fi
fi

# Symlink the bashrc files
if [ -L "${HOME}/${rcfile}" ]; then
    cmsg -y "The .bashrc symlink already exists"
elif [ -f "${HOME}/${rcfile}" ]; then
    cmsg -y "Found an existing .bashrc file"
else
    cd "$HOME" && ln -s "${DOTFILES_DIR}/bashrc/${system}/${rcfile}" .
fi

# Symlink the vimrc files
if [ -L "${HOME}/.vim" ]; then
    cmsg -y "The .vim symlink already exists"
elif [ -d "${HOME}/.vim" ]; then
    cmsg -y "Found an existing .vim directory"
else
    cd "$HOME" && ln -s "${DOTFILES_DIR}/vimrc/.vim" .
fi

if [ -L "${HOME}/.vimrc" ]; then
    cmsg -y "The .vimrc symlink already exists"
elif [ -f "${HOME}/.vimrc" ]; then
    cmsg -y "Found an existing .vimrc file"
else
    cd "$HOME" && ln -s "${DOTFILES_DIR}/vimrc/.vimrc" .
fi

# Symlink the tmux config
if [ -L "${HOME}/.tmux.conf" ]; then
    cmsg -y "The .tmux.conf symlink already exists"
elif [ -f "${HOME}/.tmux.conf" ]; then
    cmsg -y "Found an existing .tmux.conf file"
else
    cd "$HOME" && ln -s "${DOTFILES_DIR}/tmux/.tmux.conf" ".tmux.conf"
fi

if [ "$system" != "server" ]; then
    # Symlink the git config
    if [ -L "${HOME}/.gitconfig" ]; then
        cmsg -y "The .gitconfig symlink already exists"
    elif [ -f "${HOME}.gitconfig" ]; then
        cmsg -y "Found an existing .gitconfig file"
    else
        cd "$HOME" && cp "${DOTFILES_DIR}/git/.gitconfig" ".gitconfig"
    fi
fi


