# Server Aliases

if [ -x /usr/bin/dircolors ]; then
    if [ -r "${HOME}/.dircolors" ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'
    # alias dir='dir --color=auto'
    # alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Import the global aliases
if [ -f "${BASHRC_DIR}/shared/.bash_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_aliases"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/.bash_debian_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_debian_aliases"
fi

# Git aliases
alias st='git status'
