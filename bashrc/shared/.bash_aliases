# Global aliases

# Upgrade fzf
alias updatefzf='cd ~/.fzf && git pull && ./install && cd ~'

## Add an "alert" alias for long running commands. Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## Clear the screen of your clutter
alias clear='clear;pwd;'

## Use htop instead of top
alias top='htop'

## Will make any parent directories necessary
#alias mkdir="mkdir -pv"

## Make these general commands verbose and interactive
#alias rm='rm -vi'
#alias cp='cp -vi'
#alias mv='mv -vi'

## Alias for fuzzy finder
alias openit='open $(fzf -m);'
alias vimit='vim $(fzf -m);'

## Directory navigation aliases
alias cd..='cd ..' # change to parent directory, even when you forget the space.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
