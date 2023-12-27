#!/usr/bin/env bash

for script in "$(dirname "$0")/fn/"*; do
    source "$script"
done

command="$1"
shift

if [ "$command" != "clone" ] && [ "$command" != "init" ]; then
    check
fi

"$command" $@
