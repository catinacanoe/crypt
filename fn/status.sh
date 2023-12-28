#!/usr/bin/env bash

function status() {
    fetch 2>&1
    [ -f .crypt/index ] && [ -n "$(cat .crypt/index)" ] && \
	echo && echo "this crypt is behind the remote" && return

    encrypt 2>&1


    cd .crypt 2>&1
    local gitstat="$(git status 2>&1)"

    if [[ "$gitstat" == *"Your branch is ahead"* ]] || \
       [[ "$gitstat" == *"Untracked"* ]] || \
       [[ "$gitstat" == *"Changes to be committed"* ]] || \
       [[ "$gitstat" == *"Changes not staged"* ]]; then
	echo && echo "this crypt is ahead of remote" && return
    else
	echo && echo "this crypt is up to date with remote" && return
    fi

    cd .. 2>&1
}
