# .bash_profile for Joel's Mac Book Pro
# Last edited on 08/10/17

# bashrc directory
dotfiles_dir="${HOME}/repos/dotfiles"
bashrc_dir="${dotfiles_dir}/bashrc"
bin_dir="${dotfiles_dir}/bin"
sub_dir="mac"

# Shell options!

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Cmdhist
shopt -s cmdhist

# Append to the history file, don't overwrite it
shopt -s histappend

# double ** search !
# shopt -s globstar

# gpg signing
export GPG_TTY=$(tty)

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000000
export HISTFILESIZE=2000000
export HISTIGNORE="&:[ ]*:ls:ll:cd:cd ~:clear:exit:* --help"
# export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Prompt shell
export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "

# if ~/bin exists, add it to PATH
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# if dotfiles/bin exists, add it to PATH
if [ -d "${HOME}/repos/dotfiles/bin" ]; then
    export PATH="${HOME}/repos/dotfiles/bin:${PATH}"
fi

# Android Studio to Path
if [ -d "${HOME}/Library/Android" ]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export PATH="${PATH}:${ANDROID_HOME}/tools"
    export PATH="${PATH}:${ANDROID_HOME}/tools/bin"
    export PATH="${PATH}:${ANDROID_HOME}/platform-tools"

    #export JAVA_HOME="/Applications/Android\ Studio.app/Contents/jre/jdk/Contents/Home/"
fi

# Bash-Git-Prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
    . "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi

# .fzf command line fuzzy finder
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Load functions file
if [ -f "${bashrc_dir}/${sub_dir}/.bash_funct" ]; then
    . "${bashrc_dir}/${sub_dir}/.bash_funct"
fi

# Load alias definitions
if [ -f "${bashrc_dir}/${sub_dir}/.bash_aliases" ]; then
    . "${bashrc_dir}/${sub_dir}/.bash_aliases"
fi

# Load the bash completion script for .ssh 
if [ -f "${HOME}/.ssh/config" ] && [ -f "${HOME}/repos/dotfiles/bash-completion/ssh" ]; then
    . "${HOME}/repos/dotfiles/bash-completion/ssh"
fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    . "$(brew --prefix)/etc/bash_completion"
fi

## Brew Section!

# curl
if [ -d "/usr/local/opt/curl/bin" ]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

# python
if [ -d "/usr/local/opt/python@3.9/bin" ]; then
    export PATH="/usr/local/opt/python@3.9/bin:$PATH"
fi

# Andriod development
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

#yarn
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Unset any variables that were used in this script
unset bashrc_dir sub_dir

