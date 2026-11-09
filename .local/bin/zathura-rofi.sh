#!/usr/bin/env bash

SEARCH_DIRS=("$HOME/docs" "$HOME/Downloads" "$HOME/books" "$HOME/notes")

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
