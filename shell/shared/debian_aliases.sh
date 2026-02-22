# -*- shell-script -*-
# shellcheck shell=bash
# Shared desktop/server aliases — sourced by both bash and zsh

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if [ -r "${HOME}/.dircolors" ]; then
        eval "$(dircolors -b "${HOME}/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi

    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ls aliases
alias ls='ls --color=auto --group-directories-first'
alias l='ls -lhpv'    # ll without hidden files/directories
alias ll='ls -Alphv'    # Detailed ls with hidden files/directories
# alias lm='ll | more'    # Pipe through 'more'
# alias lc='ls -lhtcr'    # Sort by/show change time,most recent last
# alias lk='ls -lhrS'     # Sort by size, biggest last
# alias lt='ls -lhrt'     # Sort by date, most recent last
# alias lu='ls -lhrtu'    # Sort by/show access time,most recent last
# alias lx='ls -BlhX'     # Sort by extension

# Display directory structure
#alias lr='ll -R'       # Recursive ls
#alias lr='tree -Csh'    # Nice alternative to 'recursive ls'

# Prints disk usage in human readable form
alias duu='du -ach -d1 | sort -h'
