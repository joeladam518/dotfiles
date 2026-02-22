# -*- shell-script -*-
# shellcheck shell=bash
# Linux workstation aliases

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/shared/aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/aliases.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/debian_aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/debian_aliases.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/dev_aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/dev_aliases.sh"
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
