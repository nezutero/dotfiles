# dwl-start - dwl's startup command. Run dwl from a TTY with:
#     dwl -s dwl-start
#
# This is your hyprland exec-once list. One twist: dwl writes its live state
# (tags, layout, title, selected monitor) to THIS script's stdin, and dwlb
# reads that stream. So everything started in the background must have stdin
# redirected away from that pipe, or it swallows the state and dwl blocks.
# /dev/null rather than <&- : a *closed* fd 0 makes wl-paste abort outright
# ("launched with a closed standard file descriptor"), so hand it a real fd
# that simply reads EOF.

{
    wbg ~/Pictures/walls/your_name_sky1.jpg &

    dunst -config ~/.config/dunst/dunstrc &

    # hypridle -> swayidle. Tune these to match what your hypridle.conf did;
    # this is a plain 5-minute lock, 10-minute screen-off.
    swayidle -w \
        timeout 300 'swaylock -f' \
        timeout 600 'wlr-randr --output eDP-1 --off' \
        resume       'wlr-randr --output eDP-1 --on' \
        before-sleep 'swaylock -f' &

    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &

    battery-notify &

    # hyprsunset -> wlsunset. Commented out: wlsunset needs the
    # wlr-gamma-control protocol, which stock dwl does not implement. There is
    # a gamma-control patch in dwl-patches - apply it before enabling this.
    # wlsunset -t 4000 -T 6500 &

    # ---- wait for dwlb's socket before talking to it ----
    n=0
    while [ "$n" -lt 100 ]; do
        set -- "$XDG_RUNTIME_DIR"/dwlb/dwlb-*
        [ -S "$1" ] && break
        n=$((n + 1))
        sleep 0.1
    done

    # right-hand status line, over a pipe (free - no process per tick)
    dwl-status | dwlb -status-stdin all &

    # clock in the title slot on the left. -custom-title turns the window-title
    # area into a writable text element, so this both removes the title and
    # gives the clock a left-hand home. Costs one dwlb call per second.
    while :; do
        dwlb -title all "$(LC_TIME=en_GB.UTF-8 date '+%H:%M:%S :: %e %B, %A :: (%d/%m/%y)')"
        sleep 1
    done &
} </dev/null &

# ---- the bar itself, in the foreground, inheriting dwl's status stream ----
#
# Colour mapping follows "#workspaces button", the rule that was live under
# hyprland - not "#tags button.occupied", which was dead config:
#   active tag       -> black on #c5c9c5
#   tag with windows -> #c5c9c5 on black
#   urgent           -> black on #c34043
#
# -inactive-fg-color is ALSO the default colour of the status text, hence the
# bright #c5c9c5 rather than the dim #727169.
#
# -scale 2 MUST STAY LAST. dwlb's -scale parser passes a char** where strtoul
# wants a char**, so it writes its end-pointer over the NEXT argv slot. Last
# on the line that slot is argv[argc], which nothing reads afterwards; anywhere
# else it blanks a real option and dwlb dies with "Option '' not recognized".
exec dwlb \
    -font "JetBrainsMono Nerd Font:size=9" \
    -bottom \
    -hide-vacant-tags \
    -status-commands \
    -custom-title \
    -no-center-title \
    -vertical-padding 0 \
    -active-fg-color 000000 \
    -no-active-color-title \
    -active-bg-color c5c9c5 \
    -occupied-fg-color c5c9c5 \
    -occupied-bg-color 000000 \
    -inactive-fg-color c5c9c5 \
    -inactive-bg-color 000000 \
    -urgent-fg-color 000000 \
    -urgent-bg-color c34043 \
    -middle-bg-color 000000 \
    -middle-bg-color-selected 000000 \
    -scale 2
