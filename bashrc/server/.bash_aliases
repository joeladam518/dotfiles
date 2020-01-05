## Aliases

## Reload the .bashrc
alias breload='source ~/.bashrc; echo bash config reloaded;'

## Upgrade fzf
alias updatefzf='cd ~/.fzf && git pull && ./install && cd ~'

## Use htop instead of top
alias top='htop'

## Will make any parent directories necessary
#alias mkdir="mkdir -pv"

## Make these general commands verbose and interactive
# alias rm='rm -vi'
# alias cp='cp -vi'
# alias mv='mv -vi'

## Aliases for ls
alias ls='ls -h --color'
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.

alias ll='ls -Alpv --group-directories-first'
alias lll='ls -lp --group-directories-first'
alias lm='ll |more'        #  Pipe through 'more'
#alias lr='ll -R'           #  Recursive ls.
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

## Prints disk usage in human readable form
alias df='df -Tha --total'
alias du='du -ach | sort -h'
alias di="du -cBM -d1 2> >(grep -v 'Permission denied') | sort -n"

## Process table
alias ps="ps auxf"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

## Alias for fuzzy finder
alias openit='open $(fzf -m);'
alias vimit='vim $(fzf -m);'

## Aliases to git stuff
alias st='git status'
alias ga=GitAdd
alias gc='git commit'
alias gch='git checkout'
alias gd='git diff'
alias gp='git push'

## Aliases to git functions
alias srepo=SyncRepoFunction

## Update aliases
alias auu='sudo apt-get update && sudo apt-get -y upgrade && sudo apt autoremove'
#alias auu='sudo apt-automate'
alias aar='sudo apt autoremove'

## Clear the screen of your clutter
alias clear='clear;pwd;'

## Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# if vagrant environment
if [[ ! -z ${is_vagrant_env} && ${is_vagrant_env} == 'true' ]]; then
    # Assign hostname to variable
    sitename=$(hostname)

    # Vagrant command to run the queue worker
    alias qwork='php artisan queue:work --tries=3'

    if [ -f "${HOME}/${sitename}/aliases" ]; then
        . "${HOME}/${sitename}/aliases"
    fi
fi
