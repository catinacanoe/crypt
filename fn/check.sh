#!/usr/bin/env bash

check() {
    while true; do
	[ "$PWD" == "/" ] && break
	[ -d .crypt/ ] && return
	cd ..
    done

    echo "not a crypt repository, exiting ..."
    exit 1
}

