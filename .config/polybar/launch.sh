#!usr/bin/env sh

## Add this to your wm startup file

# Terminate already running bar instaces
killall -q polybar

# Wait until the prosses have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch bar
polybar main -c ~/.config/polybar/config.ini &
