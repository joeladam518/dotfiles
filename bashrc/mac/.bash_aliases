# Mac Aliases

# Import the global aliases
if [ -f "${bashrc_dir}/global/.bash_aliases" ]; then
    . "${bashrc_dir}/global/.bash_aliases"
fi

# Import the global aliases
if [ -f "${bashrc_dir}/global/.dev_aliases" ]; then
    . "${bashrc_dir}/global/.dev_aliases"
fi

# Reload the .bash_profile
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
alias nadmin-test="docker exec -it sourcetoad_nuggetadmin_code ./vendor/bin/phpunit"
alias nvault="cd ~/repos/ACHLink-Vault"
alias nvault-exec="docker exec -it sourcetoad_nuggetvault_code"
alias nvault-test="docker exec -it sourcetoad_nuggetvault_code ./vendor/bin/phpunit"
