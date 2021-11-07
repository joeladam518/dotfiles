# Desktop Aliases

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
alias ls-icons="find /usr/share/icons -type f \( -name '*.svg' -o -name '*.png' \) | perl -F\/ -wane 'print \$F[-1]' |sort | uniq -u | sed -E 's/(.svg|.png)//g'"

# fzf aliases
alias subit='subl $(fzf -m);'
alias codeit='code $(fzf -m);'
