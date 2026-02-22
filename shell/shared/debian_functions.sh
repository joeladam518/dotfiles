# -*- shell-script -*-
# shellcheck shell=bash
# Shared desktop/server functions — sourced by both bash and zsh

auu()
{
    # Update your computer

    if [ "$(id -u)" -eq "0" ]; then
        #apt update && apt upgrade -y && apt autoremove -y
        apt-get update && apt-get upgrade -y
    else
        #sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
        sudo apt-get update && sudo apt-get upgrade -y
    fi
}

showdns()
{
    # Show the current and closest dns resolver on the network

    local NAMESERVER
    NAMESERVER="$( ( nmcli dev list || nmcli dev show ) 2> /dev/null | grep DNS | tr -s '[:space:]' | cut -d' ' -f2 )"

    if [ -z "$NAMESERVER" ]; then
        NAMESERVER="$(cat /etc/resolv.conf | grep 'nameserver' | head -1 |cut -d' ' -f2)"
    fi

    if [ -z "$NAMESERVER" ] || [ "$NAMESERVER" = "127.0.0.53" ]; then
        NAMESERVER="$(ip route | grep default | cut -d' ' -f3)"
    fi

    if [ -z "$NAMESERVER" ]; then
        echo "Couldn't find nameserver" 1>&2
        return 1
    fi

    echo "$NAMESERVER"
    return 0
}
