# -*- shell-script -*-
# shellcheck shell=bash
# Server Aliases

# Import the global aliases
if [ -f "${BASHRC_DIR}/shared/.bash_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_aliases"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/.bash_debian_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_debian_aliases"
fi

# Git aliases
alias st='git status'
