#!/bin/sh
TEMP_FILE="/tmp/hyprsunset_temp"
DEFAULT_TEMP=4500
STEP=200
MIN_TEMP=1000
MAX_TEMP=6500

if [ -f "$TEMP_FILE" ]; then
    current=$(cat "$TEMP_FILE")
else
    current=$DEFAULT_TEMP
fi

send_notification() {
    dunstify -a "Temperature" -u low -r 9995 -h int:value:"$(( ($1 * 100) / $MAX_TEMP ))" \
        -i "display-brightness" "Color Temperature" "Currently at $1K" -t 1000
}

case $1 in
    up)
        new=$(( current + STEP ))
        [ "$new" -gt "$MAX_TEMP" ] && new=$MAX_TEMP
        ;;
    down)
        new=$(( current - STEP ))
        [ "$new" -lt "$MIN_TEMP" ] && new=$MIN_TEMP
        ;;
esac

echo "$new" > "$TEMP_FILE"
killall -w hyprsunset
hyprsunset -t "$new" &
send_notification "$new"
