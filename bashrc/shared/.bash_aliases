# -*- shell-script -*-
# shellcheck shell=bash
# Global aliases

# Reload shell
alias reload-bashrc='source ~/.bashrc;'
alias reload-shell='exec ${SHELL}; echo shell reloaded;'

# Upgrade fzf
alias updatefzf='cd ~/.fzf && git pull && ./install && cd ~'

# Clear the screen of your clutter
alias clear='clear;pwd;'

## Use htop instead of top
if command -v htop > /dev/null; then
    alias top='htop'
fi

## Alias for fuzzy finder
alias vimit='vim $(fzf -m);'

## Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
