#!/bin/bash

SEARCH_DIRS=("$HOME/Documents" "$HOME/Downloads" "$HOME/Books" "$HOME/notes")

mapfile -d '' FILES < <(fd . "${SEARCH_DIRS[@]}" -e pdf -e epub -0)

BASENAMES=()
for FILE in "${FILES[@]}"; do
    BASENAMES+=("$(basename "$FILE")")
done

SELECTED=$(printf '%s\n' "${BASENAMES[@]}" | rofi -dmenu -p "Read")

for i in "${!BASENAMES[@]}"; do
    if [[ "${BASENAMES[$i]}" == "$SELECTED" ]]; then
        zathura "${FILES[$i]}" &
        break
    fi
done
