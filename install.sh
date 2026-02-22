#!/usr/bin/env bash

set -Eeo pipefail

DOTFILES_REPO="https://github.com/joeladam518/dotfiles.git"
REPOS_DIR="${HOME}/repos"
DOTFILES_DIR="${REPOS_DIR}/dotfiles"

# Clone the repo if it doesn't exist (supports running via curl/wget pipe)
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles into ${DOTFILES_DIR}..."
    mkdir -p "${REPOS_DIR}"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Add the bin dir to path if it's not there
if [[ ! "$PATH" =~ (^|:)"$DOTFILES_DIR/bin"(:|$) ]]; then
    export PATH="${PATH}:${DOTFILES_DIR}/bin"
fi

usage() {
    echo "usage: $(basename "${0}") [-h] [--bash|--zsh] [-e {linux|mac|server}]"
    echo ""
    echo "Install dotfiles on to your machine"
    echo ""
    echo "options:"
    echo "  -h, --help                   Display this help message"
    echo "  --bash                       Install bash config (default)"
    echo "  --zsh                        Install zsh config"
    echo "  -e, --env {linux|mac|server} Override environment detection"
    echo ""
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
            # Check if a graphical desktop target is the default (workstation)
            if systemctl get-default 2>/dev/null | grep -q "graphical"; then
                echo "linux"
                return
            fi
            # Fallback: check for installed X/Wayland sessions
            if [ -d "/usr/share/xsessions" ] && [ -n "$(ls /usr/share/xsessions/ 2>/dev/null)" ]; then
                echo "linux"
                return
            fi
            if [ -d "/usr/share/wayland-sessions" ] && [ -n "$(ls /usr/share/wayland-sessions/ 2>/dev/null)" ]; then
                echo "linux"
                return
            fi
            echo "server"
            return
            ;;
        *)
            echo ""
            return
            ;;
    esac
}

# If dest is a regular file (not a symlink), back it up.
# If dest is already a symlink pointing to src, skip.
# If dest is a stale symlink, replace it.
symlink_rc() {
    local src="$1"
    local dest="$2"

    if [ -f "$dest" ] && [ ! -L "$dest" ]; then
        if [ -f "${dest}.old" ]; then
            echo "Error: ${dest}.old already exists, aborting to avoid data loss" 1>&2
            exit 1
        fi
        mv "$dest" "${dest}.old"
        cmsg -c "Backed up ${dest} → ${dest}.old"
    fi

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        cmsg -c "Already linked: $(basename "$dest")"
        return
    fi

    # Remove stale symlink (wrong target — e.g. old bashrc/ or zshrc/ path)
    if [ -L "$dest" ]; then
        rm "$dest"
    fi

    ln -s "$src" "$dest"
    cmsg -c "Linked: $(basename "$dest") → $src"
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
        cmsg -r "Error: Invalid env '${env_override}'. Must be linux, mac, or server." 1>&2
        exit 1
    fi
    env="$env_override"
else
    env="$(detect_env)"
    if [ -z "$env" ]; then
        cmsg -r "Error: Could not detect environment. Use -e {linux|mac|server} to specify." 1>&2
        exit 1
    fi
    cmsg -c "Detected environment: ${env}"
fi

# Validate combination
if [ "$shell_type" = "zsh" ] && [ "$env" = "server" ]; then
    cmsg -r "Error: zsh is not configured for server. Use --bash or -e {linux|mac}." 1>&2
    exit 1
fi

# Determine rc filename
if [ "$shell_type" = "zsh" ]; then
    rcfile=".zshrc"
elif [ "$env" = "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

rc_src="${DOTFILES_DIR}/shell/${env}/${rcfile}"
if [ ! -f "$rc_src" ]; then
    cmsg -r "Error: ${rc_src} does not exist"
    exit 1
fi

cd "$HOME" || exit 1

# Link the rc file (replaces stale symlinks from old bashrc/ or zshrc/ paths)
symlink_rc "$rc_src" "${HOME}/${rcfile}"

# Symlink the vimrc files
if [ -L "${HOME}/.vim" ]; then
    cmsg -y "Found an existing .vim directory symlink"
elif [ -d "${HOME}/.vim" ]; then
    cmsg -y "Found an existing .vim directory"
else
    ln -s "${DOTFILES_DIR}/vimrc/.vim" "${HOME}/.vim"
fi

if [ -L "${HOME}/.vimrc" ]; then
    cmsg -y "Found an existing .vimrc symlink"
elif [ -f "${HOME}/.vimrc" ]; then
    cmsg -y "Found an existing .vimrc file"
else
    ln -s "${DOTFILES_DIR}/vimrc/.vimrc" "${HOME}/.vimrc"
fi

# Symlink the tmux config
if [ -L "${HOME}/.tmux.conf" ]; then
    cmsg -y "Found an existing .tmux.conf symlink"
elif [ -f "${HOME}/.tmux.conf" ]; then
    cmsg -y "Found an existing .tmux.conf file"
else
    ln -s "${DOTFILES_DIR}/tmux/.tmux.conf" "${HOME}/.tmux.conf"
fi

# Copy git config (not for server)
if [ "$env" != "server" ]; then
    if [ -L "${HOME}/.gitconfig" ]; then
        cmsg -y "Found an existing .gitconfig symlink"
    elif [ -f "${HOME}/.gitconfig" ]; then
        cmsg -y "Found an existing .gitconfig file"
    else
        cp "${DOTFILES_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
    fi
fi
