#!/usr/bin/env bash

## Variables
CWD=$(pwd)

# First install messages in color
if [ -d "/usr/local/bin" ] && [ -e "/usr/local/bin/cmsg" ]; then
    rm /usr/local/bin/cmsg
fi

# TODO: uninstall the rest of the dotfiles
