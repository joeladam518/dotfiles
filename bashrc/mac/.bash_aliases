# -*- shell-script -*-
# shellcheck shell=bash
# Mac Aliases

# Import the global aliases
if [ -f "${BASHRC_DIR}/shared/.bash_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_aliases"
fi

# Import the development aliases
if [ -f "${BASHRC_DIR}/shared/.bash_dev_aliases" ]; then
    . "${BASHRC_DIR}/shared/.bash_dev_aliases"
fi

# Flush dns cache
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && say flushed'

# ls aliases
alias ls='ls -Gh'
alias ll='ls -aFl'
alias lll='ls -Fl'
alias lr='ll -R'

# fzf aliases - checks to see if the command exists before adding the alias
if command -v code > /dev/null; then
    alias codeit='code $(fzf -m);'
fi
if command -v open > /dev/null; then
    alias openit='open $(fzf -m);'
fi
