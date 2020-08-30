# Server Aliases

# Import the global aliases
if [ -f "${bashrc_dir}/shared/.bash_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_aliases"
fi

# Git aliases
alias st='git status'
