#!/bin/bash

# status-right:
# #[fg=colour235,bg=colour235,nobold,nounderscore,noitalics]#[fg=colour121,bg=colour235] %r  %a  %Y
# #[fg=colour238,bg=colour235,nobold,nounderscore,noitalics]#[fg=colour222,bg=colour238] #H
# #[fg=colour154,bg=colour238,nobold,nounderscore,noitalics]#[fg=colour232,bg=colour154] #(rainbarf --battery --remaining --no-rgb)

# Variables
default="#[default]"
previous="colour232"
section_start() {
    local fg="${1}"
    local bg="${2}"
    local previous_bg="${3}"
    printf "%s " "#[fg=${bg},bg=${previous_bg},nobold,nounderscore,noitalics]#[fg=${fg},bg=${bg}]"
}

date_time() {
    local previous_bg="${previous}"
    previous="colour238"
    printf "%s " "$(section_start "colour222" "colour238" "${previous_bg}")$(date +'%H:%M %Z')"
}
user() {
    local previous_bg="${previous}"
    previous="colour238"
    printf "%s " "$(section_start "colour232" "colour154" "${previous_bg}")$(whoami)@#H"
}
host() {
    local previous_bg="${previous}"
    previous="colour154"
    printf "%s " "$(section_start "colour232" "colour154" "${previous_bg}")#H"
}
user_host() {
    local previous_bg="${previous}"
    previous="colour154"
    printf "%s " "$(section_start "colour232" "colour154" "${previous_bg}")$(whoami)@#H"
}

main() {
    date_time
    user_host
}

# Calling the main function which will call the other functions.
main
