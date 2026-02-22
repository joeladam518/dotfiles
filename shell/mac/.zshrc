# -*- shell-script -*-
# ~/.zshrc: executed by zsh(1) for interactive shells on macOS

DOTFILES_DIR="${HOME}/repos/dotfiles"
HOMEBREW_DIR="/opt/homebrew"

# Auto-deduplicate PATH entries
typeset -U PATH path

# History
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=2000000
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

# GPG signing
export GPG_TTY="$(tty)"

# Oh-my-zsh
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
    git                      # git aliases + prompt info (replaces bash-git-prompt)
    fzf                      # fzf key bindings + completions
    nvm                      # lazy-loads nvm (replaces manual NVM sourcing + bash_completion)
    z                        # jump to frecently-used directories
    zsh-autosuggestions      # fish-style inline suggestions (install separately)
    zsh-syntax-highlighting  # colors valid/invalid commands (install separately)
    you-should-use           # reminds you to use aliases (install separately)
    zsh-bat                  # wraps cat with bat (install separately)
)

. "${ZSH}/oh-my-zsh.sh"

# Include the user's bin dir in PATH
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

if [ -d "${HOME}/.local/bin" ]; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ]; then
    export PATH="${DOTFILES_DIR}/bin:${PATH}"
fi

# Include brew's bin dir in PATH
if [ -d "${HOMEBREW_DIR}/bin" ]; then
    export PATH="${HOMEBREW_DIR}/bin:${PATH}"
fi

# Load aliases
if [ -f "${DOTFILES_DIR}/shell/mac_aliases.sh" ]; then
    . "${DOTFILES_DIR}/shell/mac_aliases.sh"
fi

# Load functions
if [ -f "${DOTFILES_DIR}/shell/mac_functions.sh" ]; then
    . "${DOTFILES_DIR}/shell/mac_functions.sh"
fi

# .fzf command line fuzzy finder
# Note: run `fzf --zsh` to generate ~/.fzf.zsh (requires fzf >= 0.48)
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
. <(fzf --zsh)

# Java
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:${PATH}"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
fi

# Android development
if [ -d "${HOME}/Library/Android/sdk" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/emulator"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi

# Ruby
if command -v rbenv > /dev/null; then
    eval "$(rbenv init - zsh)"
fi

# Yarn global bin
if [ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]; then
    export PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
fi

# Tizen Studio
if [ -d "${HOME}/tizen-studio" ]; then
    export PATH="${PATH}:${HOME}/tizen-studio/tools/"
    export PATH="${PATH}:${HOME}/tizen-studio/tools/ide/bin"
fi

# Rust
[ -f "${HOME}/.cargo/env" ] && . "${HOME}/.cargo/env"

# Docker Desktop
[ -f "${HOME}/.docker/init-zsh.sh" ] && . "${HOME}/.docker/init-zsh.sh"

unset DOTFILES_DIR HOMEBREW_DIR
