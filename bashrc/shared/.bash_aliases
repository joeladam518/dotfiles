# -*- shell-script -*-
# Global aliases

# Reload shell
alias reload_shell='exec ${SHELL}; echo shell reloaded;'
alias reload_bashrc='source ~/.bashrc;'

# Upgrade fzf
alias updatefzf='cd ~/.fzf && git pull && ./install && cd ~'

## Clear the screen of your clutter
alias clear='clear;pwd;'

## Use htop instead of top
alias top='htop'

## Alias for fuzzy finder
alias openit='open $(fzf -m);'
alias vimit='vim $(fzf -m);'

## Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
