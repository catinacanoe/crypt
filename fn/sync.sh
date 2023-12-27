#!/usr/bin/env bash

function sync() {
    stat="$(status)"

    case "$stat" in
        *"behind"*) echo "crypt is behind, pulling" && decrypt ;;
        *"ahead"*) echo "crypt is ahead, pushing" && commit && push ;;
        *"up to date"*) echo "crypt is up to date, nothing left to do" ;;
    esac
}
