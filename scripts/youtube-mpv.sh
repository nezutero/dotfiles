#!/usr/bin/env bash
url=$(rofi -dmenu -p "URL:" -lines 0)

if [ -z "$url" ]; then
    exit 1
fi

fmt="bestvideo[height<=1080]+bestaudio/best[height<=1080]/best"

if echo "$url" | grep -qE "[?&]list=|/playlist"; then
    mpv --ytdl-format="$fmt" --ytdl-raw-options="yes-playlist=" -- "$url" > /dev/null 2>&1 &
else
    mpv --ytdl-format="$fmt" -- "$url" > /dev/null 2>&1 &
fi

exit 0
