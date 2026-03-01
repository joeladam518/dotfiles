# -*- shell-script -*-
# ~/.zshrc: executed by zsh(1) for interactive shells on linux (Ubuntu/Debian)

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

DOTFILES_DIR="${HOME}/repos/dotfiles"
ZSH_DIR="${HOME}/.zsh"

# Prompt
PROMPT='${debian_chroot:+(${debian_chroot})}%B%F{green}%n@%m%b%f:%B%F{blue}%~%b%f%# '
RPROMPT=''

# Shell expansion (required by bash-git-prompt)
setopt PROMPT_SUBST

# Colors
autoload -U colors && colors

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

# Set variable identifying the chroot you work in (used in the prompt above)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# PATH
[ -d "${HOME}/bin" ]         && export PATH="${HOME}/bin:${PATH}"
[ -d "${HOME}/.local/bin" ]  && export PATH="${HOME}/.local/bin:${PATH}"
[ -d "${DOTFILES_DIR}/bin" ] && export PATH="${DOTFILES_DIR}/bin:${PATH}"

# zsh completions
# point git zsh completion to ~/.git-completion.bash (if present)
[ -f "${HOME}/.git-completion.bash" ] && \
    zstyle ':completion:*:*:git:*' script "${HOME}/.git-completion.bash"
# load custom completions, additional fpath dirs, and run compinit
[ -f "${DOTFILES_DIR}/zsh-completion/zsh_completion" ] && \
    . "${DOTFILES_DIR}/zsh-completion/zsh_completion"

# Load aliases
[ -f "${DOTFILES_DIR}/shell/linux/aliases.sh" ] && \
    . "${DOTFILES_DIR}/shell/linux/aliases.sh"

# Load functions
[ -f "${DOTFILES_DIR}/shell/linux/functions.sh" ] && \
    . "${DOTFILES_DIR}/shell/linux/functions.sh"

# fzf
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
[ -f ~/.fzf.zsh ] && . ~/.fzf.zsh

# nvm (lazy load for faster startup)
export NVM_DIR="${HOME}/.nvm"
if [ -d "${NVM_DIR}" ]; then
    _nvm_load() {
        unset -f nvm node npm npx _nvm_load
        [ -s "${NVM_DIR}/nvm.sh" ]          && \. "${NVM_DIR}/nvm.sh"
        [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"
    }
    nvm()  { _nvm_load; nvm  "$@"; }
    node() { _nvm_load; node "$@"; }
    npm()  { _nvm_load; npm  "$@"; }
    npx()  { _nvm_load; npx  "$@"; }
fi

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
[ -f "${HOME}/.cargo/env" ] && \
    . "${HOME}/.cargo/env"

# bash-git-prompt
if [ -f "${HOME}/.bash-git-prompt/gitprompt.sh" ]; then
    precmd() { eval $PROMPT_COMMAND; }
    __GIT_PROMPT_DIR="${HOME}/.bash-git-prompt"
    GIT_PROMPT_EXECUTABLE="git"
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_FETCH_REMOTE_STATUS=1
    . "${HOME}/.bash-git-prompt/gitprompt.sh"
fi

# zsh-bat (wraps cat with bat)
[ -f "${ZSH_DIR}/plugins/zsh-bat/zsh-bat.plugin.zsh" ] && \
    . "${ZSH_DIR}/plugins/zsh-bat/zsh-bat.plugin.zsh"

# zsh-syntax-highlighting — must be sourced last
[ -f "${ZSH_DIR}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
    . "${ZSH_DIR}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

unset DOTFILES_DIR ZSH_DIR
