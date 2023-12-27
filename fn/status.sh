#!/usr/bin/env bash

function status() {
    fetch > /dev/null 2>&1
    [ -f .crypt/index ] && [ -n "$(cat .crypt/index)" ] && \
	echo "this crypt is behind the remote" && return

    encrypt > /dev/null 2>&1

    cd .crypt
    if [[ "$(git status)" == *"Your branch is ahead"* ]] || \
       [[ "$(git status)" == *"Untracked"* ]] || \
       [[ "$(git status)" == *"Changes"* ]]; then
	echo "this crypt is ahead of remote" && return
    else
	echo "this crypt is up to date with remote" && return
    fi
    cd ..
}
