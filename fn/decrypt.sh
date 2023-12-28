#!/usr/bin/env bash

function decrypt_item() {
    local target="$(echo "$1" | sed 's|^\./||')"

    if [ -d "$target" ]; then # this typically will not be used
	shopt -s dotglob
	for item in "$1"/*; do
	    decrypt_item "$item"
	done
    elif [ -f "$target" ] && [[ "$target" == *".hash" ]]; then
	local stem="$(echo "$target" | sed 's|\.hash$||')"

        cat "$stem.p"* > ../temp.gpg # will clear the file

	echo "decrypting '$stem'"
	rm -rf "../../$stem"
	mkdir -p "../../$(dirname "$stem")"
	gpg --quiet -o "../../$stem" -d ../temp.gpg
	rm ../temp.gpg
    fi
}

function decrypt() {
    cd .crypt/data/

    local index="$(cat ../index)"
    [ -n "$index" ] && echo "$index" && echo || echo "index is blank (no modified files)"

    while IFS= read -r line; do
	local item="$(echo "$line" | sed 's|^[^ ]* ||')"
	local stem="$(echo "$item" | sed 's|\.[^.]*$||')"

	if [[ "$line" == "D"* ]]; then
	    rm -rfv "../../$stem"
	elif [[ "$line" == "M"* ]] || [[ "$line" == "A"* ]]; then
            decrypt_item "./$item"
	fi

	sed -i "\\|^$line$|d" ../index
    done <<< "$index"

    cd ../..
}
