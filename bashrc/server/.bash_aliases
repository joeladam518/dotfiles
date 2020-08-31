# Server Aliases

# Import the global aliases
if [ -f "${bashrc_dir}/shared/.bash_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_aliases"
fi

# Import aliases shared between desktop and servers
if [ -f "${bashrc_dir}/shared/.bash_debian_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_debian_aliases"
fi

# Git aliases
alias st='git status'
