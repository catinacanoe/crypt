#!/usr/bin/env bash

function encrypt_item() {
    local stem="$(echo "$1" | sed 's|^\./||')"

    if [ -d "$stem" ]; then
	[ -n "$(echo "$stem" | grep '^\.crypt')" ] && echo "INFO: skipping '$1'" && return
	[ -z "$(ls -A "$stem")" ] && echo "INFO: skipping empty '$1'" && return

	mkdir -v ".crypt/data/$stem"

	shopt -s dotglob
	for item in "$1"/*; do
	    encrypt_item "$item"
	done
    elif [ -f "$stem" ]; then
	local sum="$(sha256sum "$1" | awk '{ print $1 }')"

	if [ -n "$(grep "^$sum$" ".crypt/old/$stem.hash")" ]; then
	    # hash matches, reuse old stuff
	    for item in ".crypt/old/$stem"*; do
		cp "$item" "$(echo "$item" | sed 's|\.crypt/old|\.crypt/data|')"
	    done
	else
	    echo "encrypting $1"

	    rm ".crypt/temp.gpg" > /dev/null
	    gpg -r "$CRYPT_RECIPIENT" -o ".crypt/temp.gpg" -e "$1"
	    split -b 40m -d ".crypt/temp.gpg" ".crypt/data/$stem.p"
	    rm ".crypt/temp.gpg"

	    echo "$sum" > ".crypt/data/$stem.hash" 
	fi
    fi
}

function encrypt() {
    rm -rf .crypt/old/ > /dev/null
    mv .crypt/data/ .crypt/old/
    mkdir -v .crypt/data/

    echo "INFO: begin encryption"
    encrypt_item .
    rm -rfv .crypt/old/
}