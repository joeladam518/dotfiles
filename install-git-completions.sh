#!/usr/bin/env bash

set -Eeo pipefail

# Base URL for git completion scripts (pinned to latest stable branch)
GIT_COMPLETION_BASE_URL="https://raw.githubusercontent.com/git/git/refs/heads/master/contrib/completion"

install_zsh=0

usage() {
    echo "usage: $(basename "${0}") [-h] [--zsh]"
    echo ""
    echo "Download git completion scripts into \$HOME"
    echo ""
    echo "options:"
    echo "  -h, --help   Display this help message"
    echo "  --zsh        Also download git-completion.zsh → ~/.zsh/completions/_git"
    echo ""
}

while :; do
    case "${1-}" in
        -h | --help)
            usage
            exit 0
            ;;
        --zsh)
            install_zsh=1
            ;;
        -?*)
            echo "Error: Unknown option: ${1}" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if command -v curl >/dev/null 2>&1; then
    download() { curl -fsSL "$1" -o "$2"; }
elif command -v wget >/dev/null 2>&1; then
    download() { wget -qO "$2" "$1"; }
else
    echo "Error: curl or wget is required" >&2
    exit 1
fi

echo "Downloading git-completion.bash → ~/.git-completion.bash"
download "${GIT_COMPLETION_BASE_URL}/git-completion.bash" "${HOME}/.git-completion.bash"

if [ "$install_zsh" -eq 1 ]; then
    mkdir -p "${HOME}/.zsh/completions"
    echo "Downloading git-completion.zsh → ~/.zsh/completions/_git"
    download "${GIT_COMPLETION_BASE_URL}/git-completion.zsh" "${HOME}/.zsh/completions/_git"
fi

echo "Done."
