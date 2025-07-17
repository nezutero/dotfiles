#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <duration>"
    echo "Examples:"
    echo "  $0 25m        # 25 minutes"
    echo "  $0 300s       # 300 seconds"
    echo "  $0 1h30m      # 1 hour 30 minutes"
    exit 1
fi

parse_duration() {
    local duration="$1"
    local total_seconds=0
    
    if [[ $duration =~ ([0-9]+)h ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]} * 3600))
    fi
    
    if [[ $duration =~ ([0-9]+)m ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]} * 60))
    fi
    
    if [[ $duration =~ ([0-9]+)s ]]; then
        total_seconds=$((total_seconds + ${BASH_REMATCH[1]}))
    fi
    
    if [[ $duration =~ ^[0-9]+$ ]]; then
        total_seconds=$duration
    fi
    
    echo $total_seconds
}

format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%02d:%02d:%02d" $hours $minutes $secs
    else
        printf "%02d:%02d" $minutes $secs
    fi
}

play_timer_sound() {
    local sound_files=(
        "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
        "/usr/share/sounds/freedesktop/stereo/complete.oga"
        "/usr/share/sounds/freedesktop/stereo/bell.oga"
        "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"
        "/usr/share/sounds/Oxygen/stereo/dialog-information.ogg"
        "/usr/share/sounds/ubuntu/stereo/phone-incoming-call.ogg"
        "/usr/share/sounds/gnome/default/alerts/drip.ogg"
        "/usr/share/sounds/gnome/default/alerts/glass.ogg"
        "/usr/share/sounds/alsa/Front_Left.wav"
        "/usr/share/sounds/alsa/Front_Right.wav"
    )
    
    local sound_file=""
    
    for file in "${sound_files[@]}"; do
        if [ -f "$file" ]; then
            sound_file="$file"
            break
        fi
    done
    
    if [ -z "$sound_file" ]; then
        echo "Warning: No sound file found"
        return
    fi
    
    echo "Playing: $(basename "$sound_file")"
    
    timeout 5s bash -c "
        while true; do
            if [[ '$sound_file' == *.ogg ]] || [[ '$sound_file' == *.oga ]]; then
                if command -v ogg123 >/dev/null 2>&1; then
                    ogg123 -q '$sound_file' 2>/dev/null
                elif command -v paplay >/dev/null 2>&1; then
                    paplay '$sound_file' 2>/dev/null
                else
                    aplay '$sound_file' 2>/dev/null
                fi
            else
                aplay '$sound_file' 2>/dev/null
            fi
            sleep 0.2
        done
    " &
}

duration="$1"
total_seconds=$(parse_duration "$duration")

if [ $total_seconds -eq 0 ]; then
    echo "Error: Invalid duration format"
    exit 1
fi

echo "Timer started for $(format_time $total_seconds)"

notify-send "Timer Started" "Timer set for $(format_time $total_seconds)" -i clock

while [ $total_seconds -gt 0 ]; do
    printf "\r⏰ Time remaining: $(format_time $total_seconds)"
    sleep 1
    total_seconds=$((total_seconds - 1))
done

printf "\r%*s\r" 50 ""

echo "[OK] Timer finished!"

notify-send "Timer Finished!" "Time is up!" -i alarm-clock -u critical

play_timer_sound

echo "Timer completed successfully!"
