#!/usr/bin/env bash

function fetch() {
    cd .crypt

    echo "INFO: fetching from git"
    git fetch
    echo

    echo "INFO: updating index"

    git diff --raw main origin/main | awk '{ print $5" "$6 }' | sed 's| data/| |' >> index
    nodupes="$(sort index | uniq)"
    echo "$nodupes" > index
    [ -z "$nodupes" ] && echo "index is empty (no changed files)" || echo "$nodupes"
    echo

    echo "INFO: merging into .crypt folder"
    git merge --no-edit

    cd ..
}
