#!/usr/bin/env bash

function init() {
    [ -z "$(ls -A)" ] && echo "this directory is empty" && return
    [ -z "$1" ] && echo "please pass a remote adress" && return || remote="$1"

    [ -d ".git" ] && echo "this is already a git repo" && return
    [ -d ".crypt" ] && [ "$2" != "force" ] && echo "this is already a crypt repo" && return
    [ -f ".crypt" ] && echo "file '.crypt' is blocking" && return

    mkdir .crypt

    cd .crypt
    mkdir data
    echo "index" > .gitignore
    echo "old/" >> .gitignore
    echo "backup/" >> .gitignore
    git init
    git branch -M main
    git remote add origin "$remote"
    git add .
    git commit -m "initialize gitignore $(date)"
    git push -u origin main
    cd ..

    encrypt init

    commit
    push
}
