#!/bin/bash

# status-left:
# #[fg=colour232,bg=colour154] #S #[fg=colour154,bg=colour238,nobold,nounderscore,noitalics]
# #[fg=colour222,bg=colour238] #W #[fg=colour238,bg=colour235,nobold,nounderscore,noitalics]
# #[fg=colour121,bg=colour235] #(whoami)  #(uptime  | cut -d " " -f 1,2,3) #[fg=colour235,bg=colour235,nobold,nounderscore,noitalics]'

section_start() {
    local fg=${1}
    local bg=${2}
    printf "%s" "#[fg=${fg},bg=${bg}]"
}
section_end() {
    local fg=${1}
    local bg=${2}
    printf "%s" "#[fg=${fg},bg=${bg},nobold,nounderscore,noitalics]"
}
section_end_no_arrow() {
    local fg=${1}
    local bg=${2}
    printf "%s" "#[fg=${fg},bg=${bg},nobold,nounderscore,noitalics]"
}

cpu_temperature() {
    # Display the temperature of CPU core 0 and core 1.
    sensors -f | awk '/Core 0/{printf $3" "}/Core 1/{printf $3" "}'
}
current_pane() {
    printf "%s" "$(section_start "colour222" "colour238") #W $(section_end "colour238" "colour235")"
}
ip_address() {
    # Loop through the interfaces and check for the interface that is up.
    for file in /sys/class/net/*; do
        iface=$(basename $file);

        read status < $file/operstate;

        [ "$status" == "up" ] && ip addr show $iface | awk '/inet /{printf $2" "}'
    done
}
memory_usage() {
    if [ "$(which bc)" ]; then
        # Display used, total, and percentage of memory using the free command.
        read used total <<< $(free -m | awk '/Mem/{printf $2" "$3}')
        # Calculate the percentage of memory used with bc.
        percent=$(bc -l <<< "100 * $total / $used")
        # Feed the variables into awk and print the values with formating.
        awk -v u=$used -v t=$total -v p=$percent 'BEGIN {printf "%sMi/%sMi %.1f% ", t, u, p}'
    fi
}
session_name() {
    printf "%s" "$(section_start "colour232" "colour154") #S $(section_end "colour154" "colour238")"
}
_uptime() {
    case "$(uname -s)" in
        *Darwin*|*FreeBSD*)
            boot="$(printf "%.0f" "$(sysctl -q -n kern.boottime | awk -F'[ ,:]+' '{ print $4 }')")"
            now="$(printf "%.0f" "$(date +%s)")"
            ;;
        *Linux*|*CYGWIN*|*MSYS*|*MINGW*)
            boot="0"
            now="$(printf "%.0f" "$(cut -d " " -f1 < /proc/uptime)")"
            ;;
        *OpenBSD*)
            boot="$(printf "%.0f" "$(sysctl -n kern.boottime)")"
            now="$(printf "%.0f" "$(date +%s)")"
            ;;
    esac
    uptime="$(expr "${now}" - ${boot})"
    years="$(expr "${uptime}" / 31536000)"
    #months=""
    days="$(expr "${uptime}" / 86400)"
    hours="$(expr "$(expr "${uptime}" / 3600)" % 24)"
    minutes="$(expr "$(expr "${uptime}" / 60)" % 60)"
    #seconds="$(expr "${uptime}" % 60)"

    if [ "${years}" -gt "0" ]; then
        printf "%s" "${years}y"
    fi

    if [ "${days}" -gt "0" ]; then
        printf "%s" " ${days}d"
    fi

    if [ "${hours}" -gt "0" ]; then
        printf "%s" " ${hours}h"
    fi

    if [ "${minutes}" -gt "0" ]; then
        printf "%s" " ${minutes}m"
    fi
}
uptime() {
    printf "%s " "$(section_start "colour222" "colour238")$(_uptime) $(section_end "colour238" "colour232")"
}
vpn_connection() {
    # Check for tun0 interface.
    [ -d /sys/class/net/tun0 ] && printf "%s " 'VPN*'
}

main() {
    session_name
    uptime
}

main
