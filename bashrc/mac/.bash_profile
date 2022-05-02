# .bash_profile for Joel's Mac Book Pro

# bashrc directory
DOTFILES_DIR="${HOME}/repos/dotfiles"
BASHRC_DIR="${DOTFILES_DIR}/bashrc"
MAC_BASHRC_DIR="${BASHRC_DIR}/mac"
HOMEBREW_DIR="/opt/homebrew"

# Shell options!

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Cmdhist
shopt -s cmdhist

# Append to the history file, don't overwrite it
shopt -s histappend

# double ** search !
shopt -s globstar

# gpg signing
export GPG_TTY="$(tty)"

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTIGNORE="&:[ ]*:ls:ll:cd:cd ~:clear:exit"
# export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Prompt shell
export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "

# yarn
if [ -d "${HOME}/.yarn/bin" ]; then
    export PATH="${PATH}:${HOME}/.yarn/bin"
fi

if [ -d "${HOME}/.config/yarn/global/node_modules/.bin" ]; then
    export PATH="${PATH}:${HOME}/.config/yarn/global/node_modules/.bin"
fi

# Andriod development
if [ -d "${HOME}/Library/Android/sdk" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/emulator"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi

# include dotfiles' bin dir in the PATH
if [ -d "${DOTFILES_DIR}/bin" ]; then
    export PATH="${DOTFILES_DIR}/bin:${PATH}"
fi

# include the user's bin dir in the PATH
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# include brew's bin dir in the PATH
if [ -d "${HOMEBREW_DIR}/bin" ]; then
    export PATH="${HOMEBREW_DIR}/bin:${PATH}"
fi

# Load functions file
if [ -f "${MAC_BASHRC_DIR}/.bash_funct" ]; then
    . "${MAC_BASHRC_DIR}/.bash_funct"
fi

# Load alias definitions
if [ -f "${MAC_BASHRC_DIR}/.bash_aliases" ]; then
    . "${MAC_BASHRC_DIR}/.bash_aliases"
fi

# Bash-Git-Prompt
if [ -r "${HOMEBREW_DIR}/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    __GIT_PROMPT_DIR="${HOMEBREW_DIR}/opt/bash-git-prompt/share"
    . "${HOMEBREW_DIR}/opt/bash-git-prompt/share/gitprompt.sh"
fi

# Load custom bash completeions
if [ -f "${DOTFILES_DIR}/bash-completion/bash_completion" ] && [ -r "${DOTFILES_DIR}/bash-completion/bash_completion" ]; then
    . "${DOTFILES_DIR}/bash-completion/bash_completion"
fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
[[ -r "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh" ]] && . "${HOMEBREW_DIR}/etc/profile.d/bash_completion.sh"

# Git completion
[[ -r "${HOME}/.git-completion.bash" ]] && . "${HOME}/.git-completion.bash"

# .fzf command line fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Unset any variables that were used in this script
unset DOTFILES_DIR BASHRC_DIR MAC_BASHRC_DIR HOMEBREW_DIR

