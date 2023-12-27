#!/usr/bin/env bash

function init() {
    [ -z "$(ls -A)" ] && echo "this directory is empty" && return
    [ -z "$1" ] && echo "please pass a remote adress" && return || remote="$1"

    [ -d ".git" ] && echo "this is already a git repo" && return
    [ -d ".crypt" ] && echo "this is already a crypt repo" && return
    [ -f ".crypt" ] && echo "file '.crypt' is blocking" && return

    mkdir .crypt

    cd .crypt
    mkdir data
    echo "index" >> .gitignore
    echo "old/" >> .gitignore
    git init
    git branch -M main
    git remote add origin "$remote"
    cd ..

    encrypt
    commit

    cd .crypt
    git push -u origin main
    cd ..
}
