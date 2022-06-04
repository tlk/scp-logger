#!/bin/sh

timestamp=$(date --utc --rfc-3339=seconds)
environment=$(env | grep SSH_CONNECTION | tr '\n' ' ')
userid=$(id -u)


#
# Two kinds of log-files per user account:
#  _local  is a log of scp actions initiated from this system
#  _remote is a log of scp actions initiated from outside this system
#
get_kind() {
    while true; do
        if [ "$1" = "" ]; then
            break
        fi

        if [ "$1" = "-t" ] || [ "$1" = "-f" ]; then
            echo "remote"
            return
        fi

        shift
    done

    echo "local"
}

kind=$(get_kind "$@")

#
# Log-files must be writeable (per user)
#
logfile="/tmp/scp_uid_${userid}_${kind}.log"
echo "$timestamp	$environment	$*" >> "$logfile"


#
# Run the original scp binary
#
exec /usr/bin/scp.original "$@"