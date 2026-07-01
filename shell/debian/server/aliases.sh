# -*- shell-script -*-
# shellcheck shell=bash
# Linux server aliases

DOTFILES_DIR="${DOTFILES_DIR:-"${HOME}/repos/dotfiles"}"

if [ -f "${DOTFILES_DIR}/shell/shared/aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/aliases.sh"
fi

if [ -f "${DOTFILES_DIR}/shell/shared/debian_aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/shared/debian_aliases.sh"
fi

# Git aliases
alias st='git status'
