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

# Create the repos directory if it doesn't exist
if [ ! -d "$repos_dir" ]; then
    mkdir -p "$repos_dir"
fi

# Set the rcfile variable (because mac is different from linux)
if [ "$system" == "mac" ]; then
    rcfile=".bash_profile"
else
    rcfile=".bashrc"
fi

# Symlink the bashrc files
if [ -L "${HOME}/${rcfile}" ] && [ -f "${HOME}/${rcfile}.old" ]; then
    cmsg -y "The dotfiles .bashrc symlink already exists"
elif [ -f "${HOME}/${rcfile}" ]; then
    cd "$HOME" && mv "$rcfile" "${rcfile}.old"
    cd "$HOME" && ln -s "${repos_dir}/dotfiles/bashrc/${system}/${rcfile}" .
fi

# Symlink the vimrc files
if [ -L "${HOME}/.vimrc" ] && { [ -L "${HOME}/.vim" ] && [ -d "${HOME}/.vim" ]; }; then
    cmsg -y "The dotfiles .vimrc symlinks already exist"
else
    cd "$HOME" && ln -s "${repos_dir}/dotfiles/vimrc/.vim" .
    cd "$HOME" && ln -s "${repos_dir}/dotfiles/vimrc/.vimrc" .
fi

# TODO: intall the rest of the dotfiles

# Add Tmux config
cd "$HOME" && ln -s "${repos_dir}/dotfiles/tmux/.tmux.conf.tmp2" ".tmux.conf"

# Add git config 
if [ "$system" == "desktop" ] && [ "$system" == "mac" ]; then
    cd "$HOME" && ln -s "${repos_dir}/dotfiles/git/.gitconfig"
fi

cd "$CWD" || exit
exit

