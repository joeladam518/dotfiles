# -*- shell-script -*-
# shellcheck shell=bash
# macOS workstation aliases

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/aliases.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/dev_aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/dev_aliases.sh"
fi

# Flush dns cache
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && say flushed'

# ls aliases
alias ls='ls -Gh'
alias l='ls -Fl'
alias ll='ls -aFl'

# fzf aliases - checks to see if the command exists before adding the alias
if command -v code > /dev/null; then
    alias codeit='code "$(fzf -m)";'
fi

if command -v open > /dev/null; then
    alias openit='open "$(fzf -m)";'
fi
