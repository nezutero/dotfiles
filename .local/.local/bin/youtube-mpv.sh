#!/usr/bin/env bash

choice=$(echo -e "YouTube\nLocal Videos" | rofi -dmenu -p "Choose:")
if [ -z "$choice" ]; then
    exit 1
fi

fmt="bestvideo[height<=1080]+bestaudio/best[height<=1080]/best"

if [ "$choice" = "YouTube" ]; then
    input=$(rofi -dmenu -p "URL:" -lines 0)

    if [ -z "$input" ]; then
        exit 1
    fi

    if echo "$input" | grep -qE "[?&]list=|/playlist"; then
        mpv --ytdl-format="$fmt" --ytdl-raw-options="yes-playlist=" -- "$input" > /dev/null 2>&1 &
    else
        mpv --ytdl-format="$fmt" -- "$input" > /dev/null 2>&1 &
    fi

elif [ "$choice" = "Local Videos" ]; then
    root="$HOME/videos"
    dir="$root"

    while true; do
        entries=("[Play this folder]")
        if [ "$dir" != "$root" ]; then
            entries+=("..")
        fi

        while IFS= read -r -d '' d; do
            entries+=("$(basename "$d")/")
        done < <(find "$dir" -mindepth 1 -maxdepth 1 -type d -print0 | sort -zV)

        sel=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -p "${dir/#$root/~/videos}")

        if [ -z "$sel" ]; then
            exit 1
        fi

        case "$sel" in
            "[Play this folder]")
                break
                ;;
            "..")
                dir=$(dirname "$dir")
                ;;
            *)
                dir="$dir/${sel%/}"
                ;;
        esac
    done

    exts=(-iname "*.mp4" -o -iname "*.mkv" -o -iname "*.webm" \
          -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.m4v" -o -iname "*.flv")

    mapfile -d '' files < <(find "$dir" -type f \( "${exts[@]}" \) -print0 | sort -zV)

    if [ ${#files[@]} -eq 0 ]; then
        exit 1
    fi

    mpv -- "${files[@]}" > /dev/null 2>&1 &
fi

exit 0
