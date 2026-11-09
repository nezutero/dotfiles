#!/bin/sh
# Kanagawa theme bootstrap for Void Linux + Sway.
# Run as your normal user: sh ./install-kanagawa-void.sh
# Installs packages with sudo, writes user configs, and reloads Sway.
set -eu

# ---- Options ---------------------------------------------------------------
# Set INSTALL_PACKAGES=0 to skip XBPS installation.
INSTALL_PACKAGES="${INSTALL_PACKAGES:-1}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
THEME_DIR="$CONFIG_DIR/kanagawa"
BACKUP_DIR="$HOME/.config-backups/kanagawa-$(date +%Y%m%d-%H%M%S)"

# Kanagawa Wave palette. These are the familiar Kanagawa Wave colors.
BG="#1F1F28"
BG1="#2A2A37"
BG2="#223249"
BG3="#363646"
FG="#DCD7BA"
FG1="#C8C093"
MUTED="#727169"
RED="#E46876"
ORANGE="#FFA066"
YELLOW="#E6C384"
GREEN="#98BB6C"
CYAN="#7FB4CA"
BLUE="#7E9CD8"
PURPLE="#957FB8"
PINK="#D27E99"

say() { printf '\n==> %s\n' "$*"; }
backup() {
    f="$1"
    if [ -e "$f" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$f" "$BACKUP_DIR/"
    fi
}
write_file() {
    target="$1"
    mkdir -p "$(dirname "$target")"
    backup "$target"
    cat > "$target"
}

# ---- Packages --------------------------------------------------------------
# Package names may vary across Void repository snapshots; verify with:
#   xbps-query -Rs 'qt6ct|qt5ct|kvantum|inter|jetbrains|noto-fonts'
if [ "$INSTALL_PACKAGES" = 1 ]; then
    say "Installing useful theme/font packages (sudo required)"
    sudo xbps-install -S \
        fontconfig noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji \
        nerd-fonts adwaita-icon-theme \
        gtk+3 gtk4 gsettings-desktop-schemas \
        qt5ct qt6ct kvantum \
        sway waybar kitty
fi

# ---- Shared palette ---------------------------------------------------------
mkdir -p "$THEME_DIR"
write_file "$THEME_DIR/colors.sh" <<'EOF'
# Kanagawa Wave palette
BG="#1F1F28"
BG1="#2A2A37"
BG2="#223249"
BG3="#363646"
FG="#DCD7BA"
FG1="#C8C093"
MUTED="#727169"
RED="#E46876"
ORANGE="#FFA066"
YELLOW="#E6C384"
GREEN="#98BB6C"
CYAN="#7FB4CA"
BLUE="#7E9CD8"
PURPLE="#957FB8"
PINK="#D27E99"
EOF

# ---- GTK: preference for dark + font --------------------------------------
# For standalone Sway, GSettings is important; settings.ini is also provided
# as a fallback for GTK3 applications.
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Adwaita' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
    gsettings set org.gnome.desktop.interface font-name 'Inter 12' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 12' 2>/dev/null || true
fi

write_file "$CONFIG_DIR/gtk-3.0/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Inter 12
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

write_file "$CONFIG_DIR/gtk-4.0/settings.ini" <<'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-font-name=Inter 12
EOF

# ---- Fontconfig aliases ----------------------------------------------------
write_file "$CONFIG_DIR/fontconfig/fonts.conf" <<'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Inter</family>
      <family>Noto Sans</family>
      <family>Noto Sans CJK JP</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Noto Serif</family>
      <family>Noto Serif CJK JP</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font Mono</family>
    </prefer>
  </alias>
</fontconfig>
EOF

# ---- Cursor and Qt environment ---------------------------------------------
mkdir -p "$CONFIG_DIR/qt5ct" "$CONFIG_DIR/qt6ct" "$CONFIG_DIR/Kvantum"
write_file "$CONFIG_DIR/qt5ct/qt5ct.conf" <<'EOF'
[Appearance]
color_scheme_path=
custom_palette=false
icon_theme=Adwaita
standard_dialogs=default
style=kvantum

[Fonts]
fixed="JetBrainsMono Nerd Font Mono,12,-1,5,50,0,0,0,0,0"
general="Inter,12,-1,5,50,0,0,0,0,0"
EOF
write_file "$CONFIG_DIR/qt6ct/qt6ct.conf" <<'EOF'
[Appearance]
color_scheme=
custom_palette=false
icon_theme=Adwaita
standard_dialogs=default
style=kvantum

[Fonts]
fixed="JetBrainsMono Nerd Font Mono,12,-1,5,50,0,0,0,0,0"
general="Inter,12,-1,5,50,0,0,0,0,0"
EOF

# Kvantum's actual visual theme is separate. Use a Kanagawa Kvantum theme if
# you install one; this config selects it only if named Kanagawa exists.
write_file "$CONFIG_DIR/Kvantum/kvantum.kvconfig" <<'EOF'
[General]
theme=Kanagawa
EOF

# ---- Kitty terminal ---------------------------------------------------------
write_file "$CONFIG_DIR/kitty/kanagawa.conf" <<'EOF'
# Kanagawa Wave colors for Kitty
foreground            #DCD7BA
background            #1F1F28
selection_foreground   #DCD7BA
selection_background   #2D4F67
cursor                #C8C093
cursor_text_color     #1F1F28

# Normal
color0  #16161D
color1  #C34043
color2  #76946A
color3  #C0A36E
color4  #7E9CD8
color5  #957FB8
color6  #6A9589
color7  #C8C093

# Bright
color8  #727169
color9  #E82424
color10 #98BB6C
color11 #E6C384
color12 #7FB4CA
color13 #938AA9
color14 #7AA89F
color15 #DCD7BA
EOF

# Add include to Kitty config without overwriting user's config.
KITTY_CONF="$CONFIG_DIR/kitty/kitty.conf"
mkdir -p "$CONFIG_DIR/kitty"
touch "$KITTY_CONF"
if ! grep -Fq 'include kanagawa.conf' "$KITTY_CONF"; then
    printf '\n# Kanagawa theme (managed by install-kanagawa-void.sh)\ninclude kanagawa.conf\n' >> "$KITTY_CONF"
fi

# ---- Sway colors ------------------------------------------------------------
# Sway has no global include directive. This file is a snippet to include
# manually in ~/.config/sway/config (see instructions printed below).
write_file "$THEME_DIR/sway-colors.conf" <<'EOF'
# Kanagawa Wave Sway colors
set $kanagawa_bg #1F1F28
set $kanagawa_bg1 #2A2A37
set $kanagawa_fg #DCD7BA
set $kanagawa_muted #727169
set $kanagawa_blue #7E9CD8
set $kanagawa_red #E46876
set $kanagawa_green #98BB6C

client.focused          $kanagawa_blue $kanagawa_bg $kanagawa_fg $kanagawa_blue $kanagawa_blue
client.focused_inactive $kanagawa_bg1 $kanagawa_bg1 $kanagawa_muted $kanagawa_bg1 $kanagawa_bg1
client.unfocused        $kanagawa_bg  $kanagawa_bg  $kanagawa_muted $kanagawa_bg  $kanagawa_bg
client.urgent           $kanagawa_red $kanagawa_red $kanagawa_fg $kanagawa_red $kanagawa_red
client.placeholder      $kanagawa_bg1 $kanagawa_bg1 $kanagawa_fg $kanagawa_bg1 $kanagawa_bg1
client.background       $kanagawa_bg
EOF

# ---- Waybar CSS ------------------------------------------------------------
write_file "$CONFIG_DIR/waybar/kanagawa.css" <<'EOF'
* {
  font-family: "Inter", "Noto Sans", sans-serif;
  font-size: 12px;
  border: none;
  border-radius: 0;
  min-height: 0;
}
window#waybar {
  background: #1F1F28;
  color: #DCD7BA;
}
#workspaces button {
  padding: 0 8px;
  color: #727169;
  background: transparent;
}
#workspaces button.focused {
  color: #1F1F28;
  background: #7E9CD8;
}
#workspaces button.urgent {
  color: #1F1F28;
  background: #E46876;
}
#clock, #battery, #network, #pulseaudio, #tray {
  padding: 0 10px;
  background: #2A2A37;
  margin: 3px 2px;
}
#battery.warning { color: #E6C384; }
#battery.critical { color: #E46876; }
#network.disconnected { color: #E46876; }
EOF

# ---- Sway environment -------------------------------------------------------
# Sway imports environment variables from its config. Add these lines there
# (or place them in a file sourced by your login session).
write_file "$THEME_DIR/environment.sh" <<'EOF'
# Add to Sway config using: exec_always sh -c '...'
export GTK_THEME=Adwaita:dark
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_QPA_PLATFORM=wayland
export QT_STYLE_OVERRIDE=kvantum
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
EOF

# ---- Refresh ---------------------------------------------------------------
say "Refreshing font cache"
fc-cache -f 2>/dev/null || true

say "Theme files installed."
printf '\nNext steps:\n'
printf '  1. Add this line to ~/.config/sway/config:\n'
printf '       include %s\n' "$THEME_DIR/sway-colors.conf"
printf '  2. Add these environment lines to Sway config (before apps launch):\n'
printf '       set $gtk_theme Adwaita:dark\n'
printf '       exec_always --no-startup-id sh -c "export GTK_THEME=Adwaita:dark; export XCURSOR_THEME=Adwaita; export XCURSOR_SIZE=24"\n'
printf '     For reliable Qt environment variables, put exports in your session environment\n'
printf '     (e.g. ~/.profile or ~/.config/environment.d/90-theme.conf) and log out/in.\n'
printf '  3. For Waybar, add to its config:\n'
printf '       "style": "%s"\n' "$CONFIG_DIR/waybar/kanagawa.css"
printf '     Or append: @import url("kanagawa.css"); to your existing style.css.\n'
printf '  4. For Kitty, the script added an include to kitty.conf.\n'
printf '  5. Kvantum needs a real Kanagawa Kvantum theme installed separately.\n'
printf '     If unavailable, change qt5ct/qt6ct style to Fusion for a stable dark-ish fallback.\n'
printf '  6. Log out and back in for toolkit environment variables to apply.\n'

if command -v swaymsg >/dev/null 2>&1; then
    swaymsg reload 2>/dev/null || true
fi

if [ -d "$BACKUP_DIR" ]; then
    printf '\nPrevious configs backed up to: %s\n' "$BACKUP_DIR"
fi

