# -*- shell-script -*-
# shellcheck shell=bash
# ~/.bash_profile: executed by bash(1) for non-login shells on mac

DOTFILES_DIR="${HOME}/repos/dotfiles"
BASHRC_DIR="${DOTFILES_DIR}/bashrc"
MAC_BASHRC_DIR="${BASHRC_DIR}/mac"
HOMEBREW_DIR="/opt/homebrew"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Cmdhist
shopt -s cmdhist

# Append to the history file, don't overwrite it
shopt -s histappend

# double ** search !
shopt -s globstar

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

# include brew's bin dir in the PATH
if [ -d "${HOMEBREW_DIR}/bin" ] && [[ ! "$PATH" =~ (^|:)"${HOMEBREW_DIR}/bin"(:|$) ]]; then
    export PATH="${HOMEBREW_DIR}/bin:${PATH}"
fi

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ] && [[ ! "$PATH" =~ (^|:)"${DOTFILES_DIR}/bin"(:|$) ]]; then
    export PATH="${DOTFILES_DIR}/bin:${PATH}"
fi

# include the user's bin dir in the PATH
if [ -d "${HOME}/bin" ] && [[ ! "$PATH" =~ (^|:)"${HOME}/bin"(:|$) ]]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# Add the python directory to $PYTHONPATH so scripts can find the custom modules
# if [ -z "$PYTHONPATH" ]; then
#     export PYTHONPATH="${DOTFILES_DIR}/python"
# elif [[ ! "$PYTHONPATH" =~ (^|:)"${DOTFILES_DIR}/python"(:|$) ]]; then
#     export PYTHONPATH="${PYTHONPATH}:${DOTFILES_DIR}/python"
# fi

# Load functions file
if [ -f "${MAC_BASHRC_DIR}/.bash_functions" ]; then
    . "${MAC_BASHRC_DIR}/.bash_functions"
fi

# Load alias definitions
if [ -f "${MAC_BASHRC_DIR}/.bash_aliases" ]; then
    . "${MAC_BASHRC_DIR}/.bash_aliases"
fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [[ -r "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh" ]]; then
    . "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh"
fi

# Load custom bash completeions
if [[ -r "${DOTFILES_DIR}/bash-completion/bash_completion" ]]; then
    . "${DOTFILES_DIR}/bash-completion/bash_completion"
fi

# Enable Git bash compleation
if [[ -r "${HOME}/.git-completion.bash" ]]; then
    . "${HOME}/.git-completion.bash"
fi

# Bash-Git-Prompt
# if [ -r "${HOMEBREW_DIR}/opt/bash-git-prompt/share/gitprompt.sh" ]; then
#     GIT_PROMPT_ONLY_IN_REPO=1
#     __GIT_PROMPT_DIR="${HOMEBREW_DIR}/opt/bash-git-prompt/share"
#     . "${HOMEBREW_DIR}/opt/bash-git-prompt/share/gitprompt.sh"
# fi
if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source "$HOME/.bash-git-prompt/gitprompt.sh"
fi

# .fzf command line fuzzy finder
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

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
eval "$(rbenv init - bash)"

# # yarn
# if [ -d "${HOME}/.yarn/bin" ]; then
#     export PATH="${PATH}:${HOME}/.yarn/bin"
# fi
if [ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]; then
    export PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
fi

# Node Version Manager
if [ -d "${HOME}/.nvm" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
    [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion
fi

if [ -d "${HOME}/tizen-studio" ]; then
    export PATH="${PATH}:${HOME}/tizen-studio/tools/"
    export PATH="${PATH}:${HOME}/tizen-studio/tools/ide/bin"
fi


source "${HOME}/.docker/init-bash.sh" || true # Added by Docker Desktop

# Unset any variables that were used in this script
unset DOTFILES_DIR BASHRC_DIR MAC_BASHRC_DIR HOMEBREW_DIR
