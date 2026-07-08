# -*- shell-script -*-
# shellcheck shell=bash
# macOS workstation functions

WORK_LAPTOP="${WORK_LAPTOP:-""}"
DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/shared/functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/functions.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/dev_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/dev_functions.sh"
fi

if [ "$WORK_LAPTOP" = "1" ] && [ -f "${DOTFILES_DIR}/shell/shared/work_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/work_functions.sh"
fi

