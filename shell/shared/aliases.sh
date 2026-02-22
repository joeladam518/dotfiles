# -*- shell-script -*-
# shellcheck shell=bash
# Shared aliases — sourced by both bash and zsh

# Directory navigation aliases
alias cd..='cd ..'
alias ..='cd ..'
#alias ...='cd ../..'
#alias ....='cd ../../..'
#alias .....='cd ../../../..'

# Reload shell config
if [ -n "$ZSH_VERSION" ]; then
    alias reload-zshrc='source ~/.zshrc;'
elif [ -n "$BASH_VERSION" ]; then
    alias reload-bashrc='source ~/.bashrc;'
fi
alias reload-shell='exec ${SHELL}; echo "shell reloaded";'

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
