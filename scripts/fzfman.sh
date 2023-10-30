#!/bin/bash

selected_path=$(find . -type f -o -type d | fzf)
if [ -n "$selected_path" ]; then
    if [ -d "$selected_path" ]; then
        cd "$selected_path" || { echo "Failed to change directory"; exit 1; }
    elif [ -f "$selected_path" ]; then
        nvim "$selected_path"
    fi
else
    echo "No selection made. Exiting."
fi
