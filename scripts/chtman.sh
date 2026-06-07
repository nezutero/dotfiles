#!/usr/bin/env bash

selected=$(cat $HOME/dotfiles/scripts/chtman-langs $HOME/dotfiles/scripts/chtman-commands | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Query: " query

if grep -qs "$selected" $HOME/dotfiles/scripts/chtman-langs; then
    query=$(echo "$query" | tr ' ' '+')
    echo "curl cht.sh/$selected/$query/" && curl "cht.sh/$selected/$query" && while true; do sleep 1; done
else
    curl -s "cht.sh/$selected~$query" | less
fi
