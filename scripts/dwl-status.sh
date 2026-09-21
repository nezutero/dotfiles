# dwl-status - a waybar-shaped status line for dwlb
#
# Prints one status line per second on stdout. Feed it to a running dwlb with:
#     dwl-status | dwlb -status-stdin all
#
# dwlb has ONE status area (right-aligned), so every waybar "modules-right"
# entry is concatenated into a single string here. In-line commands:
#     ^fg(RRGGBB) / ^fg()   foreground colour / back to default
#     ^bg(RRGGBB) / ^bg()   background colour / back to default
#     ^lm(cmd) ... ^lm()    left-click region
#     ^rm(cmd) ... ^rm()    right-click region
#     ^us(cmd) / ^ds(cmd)   scroll-up / scroll-down region
#     ^^                    a literal ^
# Click commands are capped at 128 chars and run through /bin/sh -c.

# ---------------------------------------------------------------- palette ---
# Same values as your waybar style.css.
FG=c5c9c5      # normal text
DIM=727169     # separators, disconnected, muted
WARN=c0a36e     # waybar .warning
CRIT=c34043     # waybar .critical

SEP=" ^fg($DIM)│^fg($FG) "

# ------------------------------------------------------------------ icons ---
# Font Awesome / Nerd Font glyphs matching the original Waybar config.
#
# Temperature:        
# Wi-Fi:              
# Ethernet:           
# Wi-Fi disconnected: 󰖪
# Volume low/medium:   /  / 
# Mic:                 / 
# Backlight:          󰃞 / 󰃟 / 󰃠
# Bluetooth:          󰂯 / 󰂱 / 󰂲
# Battery:            󰂎 / 󰁻 / 󰁾 / 󰂀 / 󰁹
# Charging:           
# Plugged:            

# CAUTION: ^ is dwlb's escape character. If a glyph you paste contains one,
# write it as ^^ or the rest of the line is parsed as a command.

I_TEMP=""

I_WIFI=" "
I_ETH=""
I_WIFI_OFF="󰖪 "

I_VOL_LOW=""
I_VOL_MED=""
I_VOL_HIGH=" "
I_MUTE="0"

I_MIC=""
I_MIC_MUTE=" "

I_BL_LOW="󰃞"
I_BL_MED="󰃟"
I_BL_HIGH="󰃠"

I_BT="󰂯"
I_BT_CONN="󰂱"
I_BT_OFF="󰂲"

I_BAT_0="󰂎"
I_BAT_1="󰁻"
I_BAT_2="󰁾"
I_BAT_3="󰂀"
I_BAT_4="󰁹"

I_BOLT=""
I_UP="↑"
I_DOWN="↓"
I_PLUG=""

# --------------------------------------------------------------- discovery ---
# Plain globs rather than `ls`: no subprocess, and shellcheck-clean (SC2012).
# An unmatched glob stays literal, so the -d test is what rejects it.
BAT=
for d in /sys/class/power_supply/BAT*; do
    if [ -d "$d" ]; then
        BAT=$d
        break
    fi
done

BL=
for d in /sys/class/backlight/*; do
    if [ -d "$d" ]; then
        BL=$d
        break
    fi
done

TEMP=
for h in /sys/class/hwmon/hwmon*; do
    [ -r "$h/name" ] || continue
    case $(cat "$h/name") in
        coretemp | k10temp | zenpower | cpu_thermal | acpitz)
            if [ -r "$h/temp1_input" ]; then
                TEMP="$h/temp1_input"
                break
            fi
            ;;
    esac
done

if [ -z "$TEMP" ] && [ -r /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP=/sys/class/thermal/thermal_zone0/temp
fi

HAVE_BT=0
if [ -e /sys/class/bluetooth/hci0 ] && command -v bluetoothctl >/dev/null 2>&1; then
    HAVE_BT=1
fi

# ---------------------------------------------------------------- helpers ---
# col VALUE WARN_AT CRIT_AT -> prints the matching ^fg() escape
col() {
    if [ "$1" -ge "$3" ]; then
        printf '^fg(%s)' "$CRIT"
    elif [ "$1" -ge "$2" ]; then
        printf '^fg(%s)' "$WARN"
    else
        printf '^fg(%s)' "$FG"
    fi
}

# ---------------------------------------------------------------- modules ---
mod_disk() {
    p=$(df -P / | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
    printf '%s%s%% (/)^fg()' "$(col "$p" 80 90)" "$p"
}

mod_mem() {
    p=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d",(t-a)*100/t}' /proc/meminfo)
    printf '%sRAM %s%%^fg()' "$(col "$p" 80 90)" "$p"
}

# CPU needs the delta between two reads, so it writes to a global instead of
# echoing from a subshell (a $(...) subshell could not keep the previous values).
cpu_prev_total=0
cpu_prev_idle=0
cpu_pct=0

read_cpu() {
    # shellcheck disable=SC2046
    set -- $(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat)

    _idle=$(($4 + $5))
    _total=$(($1 + $2 + $3 + $4 + $5 + $6 + $7))
    _dt=$((_total - cpu_prev_total))
    _di=$((_idle - cpu_prev_idle))

    cpu_prev_total=$_total
    cpu_prev_idle=$_idle

    if [ "$_dt" -gt 0 ]; then
        cpu_pct=$(((100 * (_dt - _di)) / _dt))
    fi

    return 0
}

mod_cpu() {
    printf '%sCPU %s%%^fg()' "$(col "$cpu_pct" 80 90)" "$cpu_pct"
}

mod_temp() {
    [ -n "$TEMP" ] || return 0

    t=$(($(cat "$TEMP") / 1000))

    printf '%s%s %s°C^fg()' \
        "$(col "$t" 70 80)" \
        "$I_TEMP" \
        "$t"
}

mod_net() {
    for i in /sys/class/net/*; do
        n=${i##*/}

        [ "$n" = lo ] && continue
        [ "$(cat "$i/operstate" 2>/dev/null)" = up ] || continue

        if [ -d "$i/wireless" ]; then
            printf '%s' "$I_WIFI"
        else
            printf '%s %s' "$n" "$I_ETH"
        fi

        return 0
    done

    printf '^fg(%s)%s^fg()' "$DIM" "$I_WIFI_OFF"
}

# Bluetooth. bluetoothctl is slow to spawn, so the caller caches this.
mod_bt() {
    [ "$HAVE_BT" = 1 ] || return 0

    if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then
        printf '^lm(rofi-bluetooth)^fg(%s)%s^fg()^lm()' \
            "$DIM" \
            "$I_BT_OFF"
        return 0
    fi

    c=$(bluetoothctl devices Connected 2>/dev/null | grep -c '^Device' || echo 0)

    if [ "$c" -gt 0 ]; then
        printf '^lm(rofi-bluetooth)%s %s^lm()' \
            "$I_BT_CONN" \
            "$c"
    else
        printf '^lm(rofi-bluetooth)%s^lm()' "$I_BT"
    fi
}

# ---------------------------------------------------------------- volume ---
# Matches Waybar:
#
#     low
#     medium
#     high
#
# Waybar's:
#   format = "{volume}% {icon} {format_source}"
#
# is represented by the sink volume followed by the microphone state.

mod_vol() {
    v=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || return 0

    case $v in
        *MUTED*)
            printf '^lm(volume mute)^fg(%s)%s^fg()^lm()' \
                "$DIM" \
                "$I_MUTE"
            return 0
            ;;
    esac

    p=$(printf '%s\n' "$v" | awk '{printf "%d", $2*100}')

    if [ "$p" -lt 34 ]; then
        icon=$I_VOL_LOW
    elif [ "$p" -lt 67 ]; then
        icon=$I_VOL_MED
    else
        icon=$I_VOL_HIGH
    fi

    printf '^lm(volume mute)^rm(pavucontrol)^us(volume up)^ds(volume down)'
    printf '%s %s%%' "$icon" "$p"
    printf '^lm()^rm()^us()^ds()'
}

# = waybar's {format_source} / {format_source_muted}
mod_mic() {
    v=$(wpctl get-volume @DEFAULT_SOURCE@ 2>/dev/null) || return 0

    case $v in
        *MUTED*)
            printf '^lm(wpctl set-mute @DEFAULT_SOURCE@ toggle)'
            printf '^fg(%s)%s^fg()' \
                "$DIM" \
                "$I_MIC_MUTE"
            printf '^lm()'
            return 0
            ;;
    esac

    p=$(printf '%s\n' "$v" | awk '{printf "%d", $2*100}')

    printf '^lm(wpctl set-mute @DEFAULT_SOURCE@ toggle)%s %s%%^lm()' \
        "$I_MIC" \
        "$p"
}

# --------------------------------------------------------------- backlight ---
mod_bl() {
    [ -n "$BL" ] || return 0

    cur=$(cat "$BL/brightness")
    max=$(cat "$BL/max_brightness")
    p=$((cur * 100 / max))

    if [ "$p" -lt 34 ]; then
        icon=$I_BL_LOW
    elif [ "$p" -lt 67 ]; then
        icon=$I_BL_MED
    else
        icon=$I_BL_HIGH
    fi

    printf '^us(backlight up)^ds(backlight down)%s %s%%^us()^ds()' \
        "$icon" \
        "$p"
}

# ---------------------------------------------------------------- battery ---
mod_bat() {
    [ -n "$BAT" ] || return 0

    cap=$(cat "$BAT/capacity")
    st=$(cat "$BAT/status")

    case $((cap / 20)) in
        0) ic=$I_BAT_0 ;;
        1) ic=$I_BAT_1 ;;
        2) ic=$I_BAT_2 ;;
        3) ic=$I_BAT_3 ;;
        *) ic=$I_BAT_4 ;;
    esac

    # Remaining (or to-full) time, when the kernel exposes a rate.
    rate=0
    now=0
    full=0

    if [ -r "$BAT/power_now" ] && [ -r "$BAT/energy_now" ]; then
        rate=$(cat "$BAT/power_now")
        now=$(cat "$BAT/energy_now")
        full=$(cat "$BAT/energy_full" 2>/dev/null || echo 0)

    elif [ -r "$BAT/current_now" ] && [ -r "$BAT/charge_now" ]; then
        rate=$(cat "$BAT/current_now")
        now=$(cat "$BAT/charge_now")
        full=$(cat "$BAT/charge_full" 2>/dev/null || echo 0)
    fi

    t=

    if [ "$rate" -gt 0 ]; then
        if [ "$st" = Charging ]; then
            mins=$(((full - now) * 60 / rate))
        else
            mins=$((now * 60 / rate))
        fi

        [ "$mins" -gt 0 ] && \
            t=$(printf ' %d:%02d' \
                $((mins / 60)) \
                $((mins % 60)))
    fi

    # = Waybar's format / format-charging / format-plugged
    case $st in
        Charging)
            mark=" $I_BOLT$I_UP"
            ;;

        Discharging)
            mark=" $I_DOWN"
            ;;

        Full | "Not charging")
            mark=" $I_PLUG"
            ;;

        *)
            mark=
            ;;
    esac

    c=$FG

    if [ "$st" = Discharging ]; then
        [ "$cap" -le 30 ] && c=$WARN
        [ "$cap" -le 15 ] && c=$CRIT
    fi

    printf '^fg(%s)%s %s%%%s%s^fg()' \
        "$c" \
        "$ic" \
        "$cap" \
        "$t" \
        "$mark"
}

# ------------------------------------------------------------------- loop ---
# add ARG to $line, separated - silently skipped when the module produced
# nothing (no battery, no backlight, no wpctl, ...), so no stray separators.

line=

add() {
    [ -n "$1" ] || return 0

    if [ -z "$line" ]; then
        line=$1
    else
        line="$line$SEP$1"
    fi
}

disk=
bt=
tick=0

while :; do
    # df and bluetoothctl are the slow calls - refresh them on a longer cycle
    # like waybar's per-module intervals.
    [ $((tick % 30)) -eq 0 ] && disk=$(mod_disk)
    [ $((tick % 10)) -eq 0 ] && bt=$(mod_bt)

    read_cpu

    line=

    add "$disk"
    add "$(mod_mem)"
    add "$(mod_cpu)"
    add "$(mod_temp)"
    add "$(mod_net)"
    add "$bt"
    add "$(mod_vol)"
    add "$(mod_mic)"
    add "$(mod_bl)"
    add "$(mod_bat)"

    printf '%s\n' "$line"

    tick=$((tick + 1))
    sleep 1
done
