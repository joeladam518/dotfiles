# -*- shell-script -*-
# shellcheck shell=bash
# Desktop Aliases

# Import the shared aliases
if [ -f "${BASHRC_DIR}/shared/.bash_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_aliases"
fi

# Import the development aliases
if [ -f "${BASHRC_DIR}/shared/.bash_dev_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_dev_aliases"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/.bash_debian_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_debian_aliases"
fi

# fzf aliases - checks to see if the command exists before adding the alias
if command -v code > /dev/null; then
    alias codeit='code $(fzf -m);'
fi
if command -v xdg-open > /dev/null; then
    alias openit='xdg-open $(fzf -m);'
fi
if command -v subl > /dev/null; then
    alias sublit='subl $(fzf -m);'
fi
