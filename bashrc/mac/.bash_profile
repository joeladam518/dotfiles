# .bash_profile for Joel's Mac Book Pro
# Last edited on 08/10/17

# bashrc directory
bashrc_dir="${HOME}/repos/dotfiles/bashrc"
sub_dir="mac"

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
export HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=1000000
export HISTFILESIZE=2000000
# export HISTIGNORE="&:[ ]*:exit"
# export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S : "

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Cmdhist
shopt -s cmdhist

# Check for colored prompt shell
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# Colored prompt shell
	export PS1="\A \[\033[94m\]\w\[\033[m\]\$ "
else
	# Normal prompt shell
	export PS1="\A \w\\$ "
fi

# Consolidate all bash history from all terminals into one history
export PROMPT_COMMAND="history -a;history -c;history -r;$PROMPT_COMMAND"

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
    . $(brew --prefix)/etc/bash_completion
fi

## Unset any variables that were used in this script
unset bashrc_dir sub_dir
