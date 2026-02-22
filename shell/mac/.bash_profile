# -*- shell-script -*-
# shellcheck shell=bash
# ~/.bash_profile: executed by bash(1) for non-login shells on mac

DOTFILES_DIR="$HOME/repos/dotfiles"
HOMEBREW_DIR="/opt/homebrew"

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Cmdhist
shopt -s cmdhist

# Append to the history file, don't overwrite it
shopt -s histappend

# double ** search !
shopt -s globstar

# Set the editor
if command -v "vim" >/dev/null 2>&1; then
    export EDITOR=vim
fi

# Force the localization
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTIGNORE="&:[ ]*:ls:ll:cd:cd ~:clear:exit"

# gpg signing
export GPG_TTY="$(tty)"

# Prompt shell
export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "

# Include the user's bin dir in the PATH
if [ -d "${HOME}/bin" ] && [[ ! "$PATH" =~ (^|:)"${HOME}/bin"(:|$) ]]; then
    export PATH="${HOME}/bin:${PATH}"
fi

if [ -d "${HOME}/.local/bin" ] && [[ ! "$PATH" =~ (^|:)"${HOME}/.local/bin"(:|$) ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ] && [[ ! "$PATH" =~ (^|:)"${DOTFILES_DIR}/bin"(:|$) ]]; then
    export PATH="${DOTFILES_DIR}/bin:${PATH}"
fi

# Include brew's bin dir in the PATH
if [ -d "${HOMEBREW_DIR}/bin" ] && [[ ! "$PATH" =~ (^|:)"${HOMEBREW_DIR}/bin"(:|$) ]]; then
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

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -r "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh" ]; then
    . "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh"
fi

# Load custom bash completeions
if [ -r "${DOTFILES_DIR}/bash-completion/bash_completion" ]; then
    . "${DOTFILES_DIR}/bash-completion/bash_completion"
fi

# Enable git bash compleation
if [ -r "${HOME}/.git-completion.bash" ]; then
    . "${HOME}/.git-completion.bash"
fi

# bash-git-prompt
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    . "$HOME/.bash-git-prompt/gitprompt.sh"
fi

# .fzf command line fuzzy finder
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
eval "$(fzf --bash)"

# Java
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
fi

# Andriod development
if [ -d "${HOME}/Library/Android/sdk" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/emulator"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi

# ruby
# if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
#     export PATH="/opt/homebrew/opt/ruby/bin:${PATH}"
# fi
if command -v rbenv > /dev/null; then
    eval "$(rbenv init - bash)"
fi

# Node version manager
if [ -d "${HOME}/.nvm" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
    [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion
fi

# yarn
# if [ -d "${HOME}/.yarn/bin" ]; then
#     export PATH="${PATH}:${HOME}/.yarn/bin"
# fi
if [ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]; then
    export PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
fi

if [ -d "${HOME}/tizen-studio" ]; then
    export PATH="${PATH}:${HOME}/tizen-studio/tools/"
    export PATH="${PATH}:${HOME}/tizen-studio/tools/ide/bin"
fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

[ -f "$HOME/.docker/init-bash.sh" ] && . "${HOME}/.docker/init-bash.sh"

# Unset any variables that were used in this script
unset DOTFILES_DIR HOMEBREW_DIR
