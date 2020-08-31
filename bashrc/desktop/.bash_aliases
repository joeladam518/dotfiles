# Desktop Aliases

# Import the shared aliases
if [ -f "${bashrc_dir}/shared/.bash_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_aliases"
fi

# Import the development aliases
if [ -f "${bashrc_dir}/shared/.bash_dev_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_dev_aliases"
fi

# Import ubunutu aliases
if [ -f "${bashrc_dir}/shared/.bash_debian_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_debian_aliases"
fi

# fzf aliases
alias subit='subl $(fzf -m);'
alias codeit='code $(fzf -m);'
