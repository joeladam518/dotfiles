# .bash_profile for Joel's Mac Book Pro
# Last edited on 08/10/17

# bashrc directory
bashrc_dir="${HOME}/repos/dotfiles/bashrc"
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

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000000
export HISTFILESIZE=2000000
# export HISTIGNORE="&:[ ]*:exit"
# export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "

# Prompt shell
export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "

# if dotfiles/bin exists, add it to PATH
if [ -d "${HOME}/repos/dotfiles/bin" ]; then
    export PATH="${HOME}/repos/dotfiles/bin:${PATH}"
fi

# if ~/bin exists, add it to PATH
if [ -d "${HOME}/bin" ]; then
    export PATH="${HOME}/bin:${PATH}"
fi

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${HOME}/repos/dotfiles/bin" ]; then
    export PATH="${PATH}:${HOME}/repos/dotfiles/bin"
fi

# Bash-Git-Prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
    source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
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

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

# Unset any variables that were used in this script
unset bashrc_dir sub_dir
