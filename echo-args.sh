#!/bin/sh
readonly ec=$'\033'
readonly eend=$'\033[0m'


echoArgs() {
    local index=$1
    local count=$2
    local value=$3

   [ -t 1 ] && echo "$index/$count: $ec[1;31m[$eend$ec[0;34;42m$value$eend$ec[1;31m]$eend" || echo "$index/$count: [$value]"

}


echoArgs 0 $# "$0"
idx=1
for a;do
    echoArgs $((idx++)) $# "$a"
done
