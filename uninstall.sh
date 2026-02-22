#!/usr/bin/env bash

set -Eeo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

usage() {
    echo "usage: $(basename "${0}") [-h] [--bash|--zsh] [-e {linux|mac|server}]"
    echo ""
    echo "Uninstall dotfiles from your machine"
    echo ""
    echo "options:"
    echo "  -h, --help                   Display this help message"
    echo "  --bash                       Uninstall bash config (default)"
    echo "  --zsh                        Uninstall zsh config"
    echo "  -e, --env {linux|mac|server} Override environment detection"
}

is_valid_env() {
    echo "linux mac server" | grep -w -q "$1"
}

detect_env() {
    local os
    os="$(uname -s)"

    case "$os" in
        Darwin)
            echo "mac"
            return
            ;;
        Linux)
            if systemctl get-default 2>/dev/null | grep -q "graphical"; then
                echo "linux"
                return
            fi
            if [ -d "/usr/share/xsessions" ] && [ -n "$(ls /usr/share/xsessions/ 2>/dev/null)" ]; then
                echo "linux"
                return
            fi
            if [ -d "/usr/share/wayland-sessions" ] && [ -n "$(ls /usr/share/wayland-sessions/ 2>/dev/null)" ]; then
                echo "linux"
                return
            fi
            echo "server"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Parse options
shell_type="bash"
env_override=""

while :; do
    case "${1-}" in
        -h | --help)
            usage
            exit 0
            ;;
        --bash)
            shell_type="bash"
            ;;
        --zsh)
            shell_type="zsh"
            ;;
        -e | --env)
            if [ -z "${2-}" ]; then
                echo "Error: --env requires a value {linux|mac|server}" 1>&2
                exit 1
            fi
            env_override="$2"
            shift
            ;;
        -?*)
            echo "Unknown option: ${1}" 1>&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Determine environment
if [ -n "$env_override" ]; then
    if ! is_valid_env "$env_override"; then
        echo "Error: Invalid env '${env_override}'. Must be linux, mac, or server." 1>&2
        exit 1
    fi
    env="$env_override"
else
    env="$(detect_env)"
    if [ -z "$env" ]; then
        echo "Error: Could not detect environment. Use -e {linux|mac|server} to specify." 1>&2
        exit 1
    fi
    echo "Detected environment: ${env}"
fi

# Determine rc filename
if [ "$shell_type" = "zsh" ]; then
    rcfile=".zshrc"
elif [ "$env" = "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

cd "$HOME" || exit 1

# Remove the rc symlink
if [ -L "${HOME}/${rcfile}" ]; then
    rm -v "${HOME}/${rcfile}"
fi

# Restore backup if it exists
if [ -f "${HOME}/${rcfile}.old" ]; then
    mv "${HOME}/${rcfile}.old" "${HOME}/${rcfile}"
    echo "Restored ${rcfile}.old → ${rcfile}"
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

if [ "$env" = "server" ]; then
    exit 0
fi

if [ -L "${HOME}/.gitconfig" ]; then
    rm -iv "${HOME}/.gitconfig"
fi
