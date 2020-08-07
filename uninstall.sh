#!/usr/bin/env bash

# Variables
CWD="$(pwd)"
script_dir="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"
bin_dir="${script_dir}/bin"
repos_dir="${HOME}/repos"
system="$1"

# Add the bin dir to path if it's not there
if [[ ! "$PATH" =~ (^|:)"$bin_dir"(:|$) ]]; then
    export PATH="${PATH}:${bin_dir}"
fi

# Check if the system argument was given
if [ -z "$system" ] || { [ "$system" != "desktop" ] && [ "$system" != "mac" ] && [ "$system" != "server" ]; }; then
    cmsg -an "Must specify a type of system. "
    cmsg -a  "Valid types: {desktop|mac|server}"
    exit 1
fi

# Set the rcfile variable (because mac is different from linux)
if [ "$system" == "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

cd "$HOME"

if [ -L "${HOME}/${rcfile}" ] && [ -f "${HOME}/${rcfile}" ]; then 
    rm -v "${HOME}/${rcfile}"
fi

if [ -L "${HOME}/.vim" ] && [ -d "${HOME}/.vim" ]; then 
    rm -v "${HOME}/.vim"
fi

if [ -L "${HOME}/.vimrc" ]; then 
    rm -v "${HOME}/.vimrc"
fi

if [ -L "${HOME}/.tmux.conf" ]; then 
    rm -v "${HOME}/.tmux.conf" 
fi

if [ -L "${HOME}/.gitconfig" ]; then 
    rm -v "${HOME}/.gitconfig" 
fi

