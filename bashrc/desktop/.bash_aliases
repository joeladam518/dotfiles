# Desktop Aliases

# Import the gloabl aliases
if [ -f "${bashrc_dir}/global/.bash_aliases" ]; then
    source "${bashrc_dir}/global/.bash_aliases"
fi

# Import the development aliases
if [ -f "${bashrc_dir}/global/.dev_aliases" ]; then
    . "${bashrc_dir}/global/.dev_aliases"
fi

# Reload .bashrc
alias breload='source ~/.bashrc; echo bash config reloaded;'

# ls aliases
alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension
alias lk='ls -lSr'         #  Sort by size, biggest last
alias lt='ls -ltr'         #  Sort by date, most recent last
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last
alias lu='ls -ltur'        #  Sort by/show access time,most recent last
alias ll='ls -Alpv --group-directories-first'
alias lll='ls -lp --group-directories-first'
alias lm='ll |more'        #  Pipe through 'more'
#alias lr='ll -R'          #  Recursive ls

# Display directory structure
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls'

# Prints disk usage in human readable form
alias df='df -Tha --total'
alias du='du -ach | sort -h'
alias di="du -cBM -d1 2> >(grep -v 'Permission denied') | sort -n"

# Process table
alias ps="ps auxf"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# fzf aliases
alias subit='subl $(fzf -m);'

# apt-get aliases
alias auu='sudo apt-get update && sudo apt-get upgrade -y && sudo apt autoremove -y'
alias aar='sudo apt -y autoremove'
