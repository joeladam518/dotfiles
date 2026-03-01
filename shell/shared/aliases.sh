# -*- shell-script -*-
# shellcheck shell=bash
# Shared aliases — sourced by both bash and zsh

# Directory navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
#alias ...='cd ../..'
#alias ....='cd ../../..'
#alias .....='cd ../../../..'

# Reload shell
alias reload='exec ${SHELL}'

# Osinfo
alias osinfo='dotfiles osinfo'

# Clear the screen of your clutter
alias clear='clear;pwd;'

# Alias for fuzzy finder
alias vimit='vim "$(fzf -m)";'

# Use htop instead of top
if command -v htop > /dev/null; then
    alias top='htop'
fi
