# .bash_profile for Joel's Mac Book Pro
# Last edited on 08/10/17

bashrc_dir="${HOME}/repos/dotfiles/bashrc/mac"

## Colors  File
## If the file exists, load .bash_colors for color variable to affect the .bash output
if [ 1 ]; then
	# Colored prompt shell
	export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "
else
	# Normal prompt shell
	export PS1="\A \w\\$ "
fi

## Functions File
## If file exists load .bash_funct for general bash functions
if [ -f "$bashrc_dir"/.bash_funct ]; then
    . "$bashrc_dir"/.bash_funct
fi

## Append to the history file, don't overwrite it
shopt -s histappend

## For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000000
export HISTFILESIZE=10000000
# export HISTIGNORE="&:[ ]*:exit"
# export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "

## Don't put duplicate lines or lines starting with space in the history.
## See bash(1) for more options
# export HISTCONTROL=ignoredups:erasedups
# export HISTCONTROL=ignoreboth

## Check the window size after each command and, if necessary,
## update the values of LINES and COLUMNS.
shopt -s checkwinsize

## Cmdhist
shopt -s cmdhist

## Consolidate all bash history from all terminals into one history
export PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

## Bash Completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

## Bash-Git-Prompt
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
    source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

## Load .bash_alaises if there
if [ -f "$bashrc_dir"/.bash_aliases ]; then
    source "$bashrc_dir"/.bash_aliases
fi

## Unset any variables that were used in this script
unset bashrc_dir

