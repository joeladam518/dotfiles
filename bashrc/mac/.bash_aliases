## Aliases

## Reload the .bash_profile
alias breload='source ~/.bash_profile; say bash profile reloaded;'

## Flush dns cache
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && say flushed'

alias top=htop

## Will make any parent directories necessary
#alias mkdir="mkdir -pv"
 
## Make these general commands verbose and interactive
alias rm='rm -vi'
alias cp='cp -vi'
alias mv='mv -vi'

alias ls='ls -Gh'
alias ll='ls -aFl'
alias lll='ls -Fl'
alias lr='ll -R'
#alias ll='ls -alp | grep "^d" && ls -alp | grep "^-" && ls -alp | grep "^l"'

## Vagrant Aliases
alias vu='vagrant up'
alias vh='vagrant halt'
alias vm='vagrant ssh'

## Docker aliases
alias dkrup=dockerUpFunction
alias dkrstp=dockerStopFunction
alias dkrstpall=dockerStopAllContainersFunction
alias dkrconnect=dockerConnectToSidtkFunction
#alias dkrvm=dockerEnterContainerFunction

# aliases for repos
alias nadmin="cd ~/repos/ACHLink-Admin"
alias nadmin-exec="docker exec -it sourcetoad_nuggetadmin_code"
alias nadmin-test="docker exec -it sourcetoad_nuggetadmin_code ./vendor/bin/phpunit"
alias nadmin-cache="nadmin-exec php artisan optimize:clear && nadmin-exec composer dumpautoload"
alias nvault="cd ~/repos/ACHLink-Vault"
alias nvault-exec="docker exec -it sourcetoad_nuggetvault_code"
alias nvault-test="docker exec -it sourcetoad_nuggetvault_code ./vendor/bin/phpunit"
alias nvault-cache="nvault-exec php artisan optimize:clear && nvault-exec composer dumpautoload"

## Aliases for git stuff
alias st='git status'
alias ga=gitAdd
alias gc='git commit'
alias gd='git diff'
alias gp='git push'

## Aliases for fuzzy finder
alias openit='open $(fzf -m)'
alias vimit='vim $(fzf -m)'
alias mvimit='mvim -p --remote-tab-silent $(fzf -m)'
alias subit='sublime $(fzf -m)'

## Clear the screen of your clutter
alias clear='clear;pwd;'

## Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
