#!/usr/bin/env bash

LOW_THRESHOLD=15       # low warning %
CRITICAL_THRESHOLD=5   # critical warning %
CHECK_INTERVAL=30      # seconds between checks
NOTIF_ID=4242          # persistent notification ID

BAT_PATH="/sys/class/power_supply/BAT0"
STATUS_FILE="$BAT_PATH/status"
CAPACITY_FILE="$BAT_PATH/capacity"

last_level=-1

while true; do
    if [[ ! -f "$STATUS_FILE" || ! -f "$CAPACITY_FILE" ]]; then
        echo "Battery files not found at $BAT_PATH"
        exit 1
    fi

    STATUS=$(<"$STATUS_FILE")   # charging / discharging / full
    LEVEL=$(<"$CAPACITY_FILE")  # battery % as number

    if [[ "$STATUS" == "Discharging" ]]; then
        if (( LEVEL <= CRITICAL_THRESHOLD && last_level > CRITICAL_THRESHOLD )); then
            dunstify -u critical -r $NOTIF_ID "󰂎 Battery CRITICAL" "Level: ${LEVEL}%"  # no timeout
        elif (( LEVEL <= LOW_THRESHOLD && last_level > LOW_THRESHOLD )); then
            dunstify -u normal -r $NOTIF_ID "󰁻 Battery Low" "Level: ${LEVEL}%"  # no timeout
        fi
    else
        # clear persistent low/critical notification when charging
        dunstify -C $NOTIF_ID
    fi

    last_level=$LEVEL
    sleep $CHECK_INTERVAL
done
