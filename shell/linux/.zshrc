# -*- shell-script -*-
# ~/.zshrc: executed by zsh(1) for interactive shells on linux (Ubuntu/Debian)

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

DOTFILES_DIR="${HOME}/repos/dotfiles"
ZSHRC_DIR="${DOTFILES_DIR}/zshrc"
LINUX_ZSHRC_DIR="${ZSHRC_DIR}/linux"

# Auto-deduplicate PATH entries
typeset -U PATH path

# History
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=200000
export HISTORY_IGNORE="(ls|ll|cd|cd ~|clear|exit)"
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# Globbing
setopt EXTENDED_GLOB

# Set the editor
if command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
fi

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Oh-my-zsh
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git                      # git aliases + prompt info (replaces bash-git-prompt)
    fzf                      # fzf key bindings + completions
    nvm                      # lazy-loads nvm (replaces manual NVM sourcing)
    z                        # jump to frecently-used directories
    zsh-autosuggestions      # fish-style inline suggestions (install separately)
    zsh-syntax-highlighting  # colors valid/invalid commands (install separately)
    you-should-use           # reminds you to use aliases (install separately)
    zsh-bat                  # wraps cat with bat (install separately)
)

. "${ZSH}/oh-my-zsh.sh"

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ]; then
    PATH="${PATH}:${DOTFILES_DIR}/bin"
fi

# Load aliases
if [ -f "${DOTFILES_DIR}/shell/linux/aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/linux/aliases.sh"
fi

# Load functions
if [ -f "${DOTFILES_DIR}/shell/linux/functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/linux/functions.sh"
fi

# .fzf command line fuzzy finder
# Note: run `fzf --zsh` to generate ~/.fzf.zsh (requires fzf >= 0.48)
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
. <(fzf --zsh)

# Bun
if [ -r "${HOME}/.bun" ]; then
    export BUN_INSTALL="${HOME}/.bun"
    export PATH="${BUN_INSTALL}/bin:${PATH}"
fi

# Android
if [ -d "${HOME}/Android/Sdk" ]; then
    export ANDROID_HOME="${HOME}/Android/Sdk"
    export PATH="${PATH}:${ANDROID_HOME}/emulator"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi

# Go
if [ -d "/usr/local/go/bin" ]; then
    PATH="${PATH}:/usr/local/go/bin"
fi

# Rust
if [ -f "${HOME}/.cargo/env" ]; then
    . "${HOME}/.cargo/env"
fi

unset DOTFILES_DIR ZSHRC_DIR LINUX_ZSHRC_DIR
