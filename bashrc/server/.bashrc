# -*- shell-script -*-
# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# bashrc directory
DOTFILES_DIR="${HOME}/repos/dotfiles"
BASHRC_DIR="${DOTFILES_DIR}/bashrc"
SERVER_BASHRC_DIR="${BASHRC_DIR}/server"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Cmdhist
shopt -s cmdhist

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Append to the history file, don't overwrite it
shopt -s histappend

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTIGNORE="&:[ ]*:ls:ll:cd:cd ~:clear:exit"

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# Uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	   ## We have color support; assume it's compliant with Ecma-48
	   ## (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	   ## a case would tend to support setf rather than setaf.)
	   color_prompt=yes
    else
	   color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

unset color_prompt force_color_prompt

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# if the dotfiles bin folder exists, add it to PATH
if [ -d "${DOTFILES_DIR}/bin" ] && [[ ! "$PATH" =~ (^|:)"${DOTFILES_DIR}/bin"(:|$) ]]; then
    PATH="${PATH}:${DOTFILES_DIR}/bin"
fi

# Load functions
if [ -f "${SERVER_BASHRC_DIR}/.bash_functions" ]; then
    . "${SERVER_BASHRC_DIR}/.bash_functions"
fi

# Load aliases
if [ -f "${SERVER_BASHRC_DIR}/.bash_aliases" ]; then
    . "${SERVER_BASHRC_DIR}/.bash_aliases"
fi

# Bash-Git-Prompt
if [ -f "${HOME}/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_FETCH_REMOTE_STATUS=1
    . "${HOME}/.bash-git-prompt/gitprompt.sh"
fi

# .fzf command line fuzzy finder
export FZF_DEFAULT_COMMAND="set -o pipefail; find . | cut -b3-"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f "/usr/share/bash-completion/bash_completion" ]; then
        . "/usr/share/bash-completion/bash_completion"
    elif [ -f "/etc/bash_completion" ]; then
        . "/etc/bash_completion"
    fi
fi

unset DOTFILES_DIR BASHRC_DIR SERVER_BASHRC_DIR
