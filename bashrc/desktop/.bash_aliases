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

# fzf aliases
alias codeit='code $(fzf -m);'
alias openit='open $(fzf -m);'
alias sublit='subl $(fzf -m);'
