# Desktop Aliases

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    if [ -r "${HOME}/.dircolors" ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Import the shared aliases
if [ -f "${BASHRC_DIR}/shared/.bash_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_aliases"
fi

# Import the development aliases
if [ -f "${BASHRC_DIR}/shared/.bash_dev_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_dev_aliases"
fi

# Import aliases shared between desktop and servers
if [ -f "${BASHRC_DIR}/shared/.bash_debian_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_debian_aliases"
fi

# list avaiable icons
alias list-icons="find /usr/share/icons -type f \( -name '*.svg' -o -name '*.png' \) | perl -F\/ -wane 'print \$F[-1]' |sort | uniq -u | sed -E 's/(.svg|.png)//g'"

# fzf aliases
alias subit='subl $(fzf -m);'
alias codeit='code $(fzf -m);'
