#!/usr/bin/env bash

function clone() {
    [ -z "$1" ] && echo "please pass remote adress" && return || remote="$1"
    [ -z "$2" ] && echo "please pass target directory" && return || name="$2"

    [ -f "$name" ] && echo "target is already a file" && return
    [ -d "$name" ] && [ -n "$(ls -A "$name")" ] && echo "target is already a populated directory" && return
    
    mkdir -pv "$name"
    cd "$name"

    git clone "$remote" ".crypt/" || return

    echo "M ." > ".crypt/index"
    mkdir -pv ".crypt/data"

    decrypt
}

