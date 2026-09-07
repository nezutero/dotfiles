hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = 1.25,
})

local terminal = "foot"
local fileManager = "yazi"
local menu = "rofi -show drun"
local editor = "nvim"
local browser = "zen-beta"
local player = "foot --title rmpc -e sh -c 'rmpc update && rmpc'"

-- autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")

    hl.exec_cmd("dunst -config ~/.config/dunst/dunstrc")

    hl.exec_cmd("clipmenud")

    hl.exec_cmd("battery_notify.sh")

    hl.exec_cmd("hyprsunset -t 4000")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")


end)

-- env vars
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env(
    "PATH",
    os.getenv("HOME") ..
    "/.local/bin:" ..
    "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
)

-- xwayland
hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-- look and feel
hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,

        border_size = 0,

        col = {
            active_border = {
                colors = {
                    "rgba(33ccffee)",
                    "rgba(00ff99ee)",
                },
                angle = 45,
            },

            inactive_border = "rgba(595959aa)",
        },

        layout = "dwindle",

        allow_tearing = false,
    },

    decoration = {
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
        },
    },

    animations = {
        enabled = false,
    },

    ecosystem = {
        no_update_news = true,
    },

    misc = {
        force_default_wallpaper = 0,
    },

    cursor = {
        inactive_timeout = 3,
    },


})

-- input/keyboard
hl.config({
    input = {
        kb_layout = "us,ca",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape, grp:alt_space_toggle",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = -0.1,

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- gestures
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- per-device input
hl.device({
    name = "epic-mouse-v1",
    sensitivity = 0.2,
})

---- DWINDLE --------

-- keybindings
local mainMod = "SUPER"

-- apps

-- terminal
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))

-- browser
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))

-- close window
hl.bind(mainMod .. " + W", hl.dsp.window.close())

-- file manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal .. " -e " .. fileManager))

-- bluetooth
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("rofi-bluetooth"))

-- youtube / mpv
hl.bind(
    mainMod .. " + H",
    hl.dsp.exec_cmd("youtube-mpv.sh")
)

-- zathura launcher
hl.bind(
    mainMod .. " + R",
    hl.dsp.exec_cmd("zathura-rofi.sh")
)

-- notes
hl.bind(
    mainMod .. " + N",
    hl.dsp.exec_cmd("foot -D $HOME/notes -e nvim .")
)

-- rofi launcher
hl.bind(
    mainMod .. " + Space",
    hl.dsp.exec_cmd(
        menu .. " & sleep 0.2; hyprctl dispatch focuswindow '^(rofi)$'"
    )
)

-- password manager
hl.bind(
    mainMod .. " + P",
    hl.dsp.exec_cmd("rofipass.sh")
)

-- clipboard manager
hl.bind(
    mainMod .. " + C",
    hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy")
)

-- audacity
hl.bind(
    mainMod .. " + A",
    hl.dsp.exec_cmd("GDK_BACKEND=x11 audacity")
)

-- music player
hl.bind(
    mainMod .. " + S",
    hl.dsp.exec_cmd(player)
)

-- vesktop
hl.bind(
    mainMod .. " + D",
    hl.dsp.exec_cmd("vesktop")
)

-- signal
hl.bind(
    mainMod .. " + G",
    hl.dsp.exec_cmd("signal-desktop")
)

---- waybar -------
hl.bind(
    mainMod .. " + M",
    hl.dsp.exec_cmd("waybar")
)

hl.bind(
    mainMod .. " + K",
    hl.dsp.exec_cmd("pkill waybar")
)

---- lock -------
hl.bind(
    mainMod .. " + L",
    hl.dsp.exec_cmd("hyprlock")
)

---- window navigation --
hl.bind(
    mainMod .. " + left",
    hl.dsp.focus({ direction = "left" })
)

hl.bind(
    mainMod .. " + right",
    hl.dsp.focus({ direction = "right" })
)

hl.bind(
    mainMod .. " + up",
    hl.dsp.focus({ direction = "up" })
)

hl.bind(
    mainMod .. " + down",
    hl.dsp.focus({ direction = "down" })
)

---- workspaces -------
for i = 1, 10 do
    local key = i % 10

    -- switch workspace
    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    -- move active window to workspace
    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )


end

---- previous workspace -----
hl.bind(
    mainMod .. " + TAB",
    hl.dsp.focus({ workspace = "prev" })
)

---- workspace scrolling -----
hl.bind(
    mainMod .. " + mouse_down",
    hl.dsp.focus({ workspace = "e+1" })
)

hl.bind(
    mainMod .. " + mouse_up",
    hl.dsp.focus({ workspace = "e-1" })
)

---- move / resize -------
hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

---- screenshot --
-- screenshot -> clipboard
hl.bind(
    "Print",
    hl.dsp.exec_cmd(
        [[sh -c 'grim -g "$(slurp)" - | wl-copy -t image/png &&
        dunstify -a "Screenshot" -u low -r 9001 -t 1500 "Screenshot" "Copied to clipboard"']]
    )
)

-- screenshot -> file
hl.bind(
    mainMod .. " + Print",
    hl.dsp.exec_cmd(
        [[sh -c 'FILE="$HOME/pics/screenshots/$(date +%Y-%m-%d-%H-%M-%S).png" &&
        grim -g "$(slurp)" "$FILE" &&
        dunstify -a "Screenshot" -u low -r 9002 -t 1500 "Screenshot Saved" "$FILE"']]
    )
)

---- brightness / temper --
-- normal brightness
hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("backlight.sh up"),
    { repeating = true }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("backlight.sh down"),
    { repeating = true }
)

-- maximum / minimum brightness
hl.bind(
    "SUPER + XF86MonBrightnessUp",
    hl.dsp.exec_cmd("backlight.sh max")
)

hl.bind(
    "SUPER + XF86MonBrightnessDown",
    hl.dsp.exec_cmd("backlight.sh min")
)

-- color temperature
hl.bind(
    "CTRL + XF86MonBrightnessUp",
    hl.dsp.exec_cmd("temperature.sh up")
)

hl.bind(
    "CTRL + XF86MonBrightnessDown",
    hl.dsp.exec_cmd("temperature.sh down")
)

---- volume -------
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("volume.sh up"),
    { repeating = true }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("volume.sh down"),
    { repeating = true }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("volume.sh mute")
)

---- microphone ------
hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle")
)

---- power menu ----
hl.bind(
    "XF86Favorites",
    hl.dsp.exec_cmd(
        "rofi -show power-menu -modi power-menu:rofi-power-menu.sh"
    )
)

hl.bind(
    "XF86Tools",
    hl.dsp.exec_cmd("foot -D $HOME/dotfiles -e nvim .")
)
