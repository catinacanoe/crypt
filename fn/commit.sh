#!/usr/bin/env bash

function commit() {
    cd .crypt/
    git add .
    git commit -m "from $(whoami)@$(hostname) at $(date +"%H:%M on %a %d.%m.%Y")"
    cd ..
}
