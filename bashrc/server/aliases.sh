# -*- shell-script -*-
# shellcheck shell=bash
# Server Aliases

# Import the global aliases
if [ -f "${BASHRC_DIR}/shared/aliases.sh" ]; then
    . "${BASHRC_DIR}/shared/aliases.sh"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/debian_aliases.sh" ]; then
    . "${BASHRC_DIR}/shared/debian_aliases.sh"
fi

# Git aliases
alias st='git status'
