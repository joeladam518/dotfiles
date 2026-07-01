# -*- shell-script -*-
# shellcheck shell=bash
# Linux server functions

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/shared/functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/functions.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/debian_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/debian_functions.sh"
fi
