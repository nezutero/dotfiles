#!/usr/bin/env bash

get_volume() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}'
}

get_mute() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no"
}

send_notification() {
	volume=$(get_volume)
	mute=$(get_mute)

	if [ "$mute" = "yes" ]; then
		dunstify -a "Volume" -u low -r 9993 -i "audio-volume-muted" "Volume" "Muted" -t 1000
		return
	fi

	if [ "$volume" -eq 0 ]; then
		icon="audio-volume-muted"
	elif [ "$volume" -lt 30 ]; then
		icon="audio-volume-low"
	elif [ "$volume" -lt 70 ]; then
		icon="audio-volume-medium"
	else
		icon="audio-volume-high"
	fi

	dunstify -a "Volume" -u low -r 9993 -h int:value:"$volume" -i "$icon" "Volume" "Currently at $volume%" -t 1000
}

case $1 in
	up)
		wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
		send_notification
		;;
	down)
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
		send_notification
		;;
	mute)
		wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
		send_notification
		;;
	max)
		wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
		wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
		send_notification
		;;
esac
