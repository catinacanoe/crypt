#!/usr/bin/env bash

check() {
    if ! [ -d .crypt/ ]; then
        echo "not a crypt repository, exiting ..."
        exit 1
    fi
}

