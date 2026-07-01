# -*- shell-script -*-
# shellcheck shell=bash
# Linux workstation functions

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/shared/functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/functions.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/debian_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/debian_functions.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/dev_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/dev_functions.sh"
fi
