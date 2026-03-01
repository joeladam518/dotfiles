# -*- shell-script -*-
# ~/.zshrc: executed by zsh(1) for interactive shells on macOS

DOTFILES_DIR="${HOME}/repos/dotfiles"
HOMEBREW_DIR="/opt/homebrew"
ZSH_DIR="${HOME}/.zsh"

# Prompt
PROMPT='%T %F{12}%~%f%(#.#.$) '
RPROMPT=''

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

# Shell expansion (required by bash-git-prompt)
setopt PROMPT_SUBST

# Colors
autoload -U colors && colors
export CLICOLOR=1

# Preferred editor for local and remote sessions
if command -v vim >/dev/null 2>&1; then
    export EDITOR=vim
fi

# PATH
[ -d "${HOME}/bin" ]         && export PATH="${HOME}/bin:${PATH}"
[ -d "${HOME}/.local/bin" ]  && export PATH="${HOME}/.local/bin:${PATH}"
[ -d "${DOTFILES_DIR}/bin" ] && export PATH="${DOTFILES_DIR}/bin:${PATH}"
[ -d "${HOMEBREW_DIR}/bin" ] && export PATH="${HOMEBREW_DIR}/bin:${PATH}"

# zsh completions
# point git zsh completion scrip to this .git-completion.bash
[ -f "${HOME}/.git-completion.bash" ] && \
    zstyle ':completion:*:*:git:*' script "${HOME}/.git-completion.bash"
# additional completion directories
DOTFILES_ZSH_COMPLETION_DIRECTORIES=(
    "${ZSH_DIR}/completions"
    "${HOMEBREW_DIR}/share/zsh/site-functions"
)
# load zsh completions
[ -f "${DOTFILES_DIR}/zsh-completion/zsh_completion" ] && \
    . "${DOTFILES_DIR}/zsh-completion/zsh_completion"

# Load aliases
[ -f "${DOTFILES_DIR}/shell/mac/aliases.sh" ] && \
    . "${DOTFILES_DIR}/shell/mac/aliases.sh"

# Load functions
[ -f "${DOTFILES_DIR}/shell/mac/functions.sh" ] && \
    . "${DOTFILES_DIR}/shell/mac/functions.sh"

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
[ -f "${HOME}/.cargo/env" ] && \
    . "${HOME}/.cargo/env"

# Docker Desktop
[ -f "${HOME}/.docker/init-zsh.sh" ] && \
    . "${HOME}/.docker/init-zsh.sh"

# bash-git-prompt
if [ -f "${HOME}/.bash-git-prompt/gitprompt.sh" ]; then
    precmd() { eval $PROMPT_COMMAND; }
    __GIT_PROMPT_DIR="$HOME/.bash-git-prompt"
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

unset DOTFILES_DIR HOMEBREW_DIR ZSH_DIR
