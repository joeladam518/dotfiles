# Mac Aliases

# Import the global aliases
if [ -f "${bashrc_dir}/shared/.bash_aliases" ]; then
    . "${bashrc_dir}/shared/.bash_aliases"
fi

# Import the development aliases
if [ -f "${bashrc_dir}/shared/.dev_aliases" ]; then
    . "${bashrc_dir}/shared/.dev_aliases"
fi

# Reload .bash_profile
alias breload='source ~/.bash_profile; echo bash config reloaded;'

# Flush dns cache
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && say flushed'

# ls aliases
alias ls='ls -Gh'
alias ll='ls -aFl'
alias lll='ls -Fl'
alias lr='ll -R'

# fzf aliases
alias subit='sublime $(fzf -m)'
alias mvimit='mvim -p --remote-tab-silent $(fzf -m)'

# Docker aliases
alias dkrconnect=dockerConnectToSidtkFunction
alias dkrup=dockerUpFunction
alias dkrstp=dockerStopFunction
alias dkrstpall=dockerStopAllContainersFunction

# Sourcetoad repo aliases
alias nadmin="cd ~/repos/ACHLink-Admin"
alias nadmin-exec="docker exec -it sourcetoad_nuggetadmin_code"
alias nvault="cd ~/repos/ACHLink-Vault"
alias nvault-exec="docker exec -it sourcetoad_nuggetvault_code"
alias nqa="cd ~/repos/ACHLink-QA-Site"
alias nqa-exec="docker exec -it sourcetoad_nuggetqa_code"

