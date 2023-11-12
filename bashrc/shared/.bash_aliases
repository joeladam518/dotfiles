# -*- shell-script -*-
# shellcheck shell=bash
# Shared aliases

# Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Reload shell
alias reload-bashrc='source ~/.bashrc;'
alias reload-shell='exec ${SHELL}; echo "shell reloaded";'

# Clear the screen of your clutter
alias clear='clear;pwd;'

# Alias for fuzzy finder
alias vimit='vim $(fzf -m);'

# Use htop instead of top
if command -v htop > /dev/null; then
    alias top='htop'
fi
