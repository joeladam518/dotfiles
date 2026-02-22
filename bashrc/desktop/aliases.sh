# -*- shell-script -*-
# shellcheck shell=bash
# Desktop Aliases

# Import the shared aliases
if [ -f "${BASHRC_DIR}/shared/aliases.sh" ]; then
    . "${BASHRC_DIR}/shared/aliases.sh"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/debian_aliases.sh" ]; then
    . "${BASHRC_DIR}/shared/debian_aliases.sh"
fi

# Import the development aliases
if [ -f "${BASHRC_DIR}/shared/dev_aliases.sh" ]; then
    . "${BASHRC_DIR}/shared/dev_aliases.sh"
fi

# fzf aliases - checks to see if the command exists before adding the alias
if command -v code > /dev/null; then
    alias codeit='code "$(fzf -m)";'
fi

if command -v xdg-open > /dev/null; then
    alias openit='xdg-open "$(fzf -m)";'
fi

if command -v subl > /dev/null; then
    alias sublit='subl "$(fzf -m)";'
fi
