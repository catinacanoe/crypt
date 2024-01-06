#!/usr/bin/env bash

function commit() {
    [ "$1" == "nocd" ] || cd .crypt/
    git add .
    git commit -m "from $(whoami)@$(hostname) at $(date +"%H:%M on %a %d.%m.%Y")"
    [ "$1" == "nocd" ] || cd ..
}
