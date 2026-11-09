#!/usr/bin/env bash
# Void Linux bootstrap approximating the supplied NixOS configuration.
# Review first. Run as your regular user: bash init.sh
set -Eeuo pipefail

[[ $EUID -ne 0 ]] || { echo "Run as regular user, not root."; exit 1; }
command -v sudo >/dev/null || { echo "Install/configure sudo first."; exit 1; }
USER_NAME="${USER:-$(id -un)}"
TIMEZONE="Europe/Paris"

say(){ printf "\n==> %s\n" "$*"; }
install_available() {
  local p
  for p in "$@"; do
    if xbps-query -Rs "^${p}-" >/dev/null 2>&1; then
      sudo xbps-install -y "$p" || echo "WARN: install failed: $p"
    else
      echo "Skipping unavailable package: $p"
    fi
  done
}
enable_service() {
  local s="$1"
  if [[ -d "/etc/sv/$s" ]]; then
    sudo ln -snf "/etc/sv/$s" "/var/service/$s"
    echo "Enabled runit service: $s"
  else
    echo "No /etc/sv/$s; skipped"
  fi
}

say "Updating repositories"
sudo xbps-install -S

say "Installing base packages"
install_available \
  zsh git wget bind-utils jq fzf fd tree ncdu btop fastfetch killall zip unzip yazi zbar imagemagick \
  gnupg pass tmux gcc gdb glibc-devel go rust nodejs python3 openjdk21 \
  podman docker distrobox qemu pandoc typst zathura \
  fontconfig noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji nerd-fonts adwaita-icon-theme \
  dbus elogind polkit NetworkManager udisks2 gvfs

say "Installing Sway desktop"
install_available \
  sway swayidle swaybg swaylock wlsunset waybar greetd tuigreet foot kitty rofi dunst libnotify \
  cliphist wl-clipboard grim slurp wtype wev brightnessctl pavucontrol \
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
  qt5ct qt6ct kvantum gtk+3 gtk4 gsettings-desktop-schemas

say "Installing development tools"
install_available clang make cmake pkg-config go rust cargo nodejs python3 jdk21 vscodium android-tools

say "Installing media and messaging packages"
install_available imv mpv obs thunderbird telegram-desktop signal-desktop

say "Enabling runit services (verify service names on your Void installation)"
enable_service dbus
enable_service elogind
enable_service polkitd
enable_service NetworkManager
enable_service udisksd

say "Setting timezone and locales"
if [[ -e "/usr/share/zoneinfo/$TIMEZONE" ]]; then
  sudo ln -snf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  echo "$TIMEZONE" | sudo tee /etc/timezone >/dev/null
fi
if [[ -f /etc/default/libc-locales ]]; then
  sudo cp -a /etc/default/libc-locales "/etc/default/libc-locales.bak.$(date +%s)"
  sudo sed -i \
    -e 's/^#\?en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
    -e 's/^#\?en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' \
    -e 's/^#\?fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' \
    /etc/default/libc-locales
  sudo xbps-reconfigure -f glibc-locales || true
fi
sudo tee /etc/locale.conf >/dev/null <<'EOF_LOCALE'
LANG=en_US.UTF-8
LC_ADDRESS=fr_FR.UTF-8
LC_IDENTIFICATION=fr_FR.UTF-8
LC_MEASUREMENT=fr_FR.UTF-8
LC_MONETARY=fr_FR.UTF-8
LC_NAME=fr_FR.UTF-8
LC_NUMERIC=fr_FR.UTF-8
LC_PAPER=fr_FR.UTF-8
LC_TELEPHONE=fr_FR.UTF-8
LC_TIME=en_GB.UTF-8
EOF_LOCALE

say "Setting user shell and groups"
if [[ -x /usr/bin/zsh ]]; then sudo chsh -s /usr/bin/zsh "$USER_NAME" || true; fi
for g in wheel network kvm; do
  getent group "$g" >/dev/null && sudo usermod -aG "$g" "$USER_NAME" || true
done

say "NetworkManager DNS default"
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/10-dns.conf >/dev/null <<'EOF_NM'
[main]
dns=default
EOF_NM

say "Setting up greetd if available"
if [[ -d /etc/sv/greetd ]]; then
  sudo mkdir -p /etc/greetd
  if [[ ! -e /etc/greetd/config.toml ]]; then
    sudo tee /etc/greetd/config.toml >/dev/null <<'EOF_GREETD'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd sway"
user = "_greeter"
EOF_GREETD
  fi
  enable_service greetd
else
  echo "greetd service unavailable; configure your login manager manually."
fi

say "Writing desktop environment variables"
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/90-desktop.conf" <<'EOF_ENV'
XCURSOR_THEME=Adwaita
XCURSOR_SIZE=24
PASSWORD_STORE_ENABLE_EXTENSIONS=true
MOZ_ENABLE_WAYLAND=1
GTK_THEME=Adwaita:dark
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=kvantum
EOF_ENV

# If Sway is launched from a Zsh login, load env vars through ~/.zprofile.
touch "$HOME/.zprofile"
if ! grep -q '90-desktop.conf' "$HOME/.zprofile"; then
cat >> "$HOME/.zprofile" <<'EOF_ZPROFILE'

# Void/Sway desktop environment
if [[ -r "$HOME/.config/environment.d/90-desktop.conf" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    export "$key=$value"
  done < "$HOME/.config/environment.d/90-desktop.conf"
fi
EOF_ZPROFILE
fi

say "Writing fonts, GTK and Qt settings"
mkdir -p "$HOME/.config/fontconfig" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/qt5ct" "$HOME/.config/qt6ct" "$HOME/.config/Kvantum"
cat > "$HOME/.config/fontconfig/fonts.conf" <<'EOF_FONT'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
 <alias><family>sans-serif</family><prefer><family>Inter</family><family>Noto Sans</family><family>Noto Sans CJK JP</family></prefer></alias>
 <alias><family>serif</family><prefer><family>Noto Serif</family><family>Noto Serif CJK JP</family></prefer></alias>
 <alias><family>monospace</family><prefer><family>JetBrainsMono Nerd Font Mono</family></prefer></alias>
</fontconfig>
EOF_FONT
cat > "$HOME/.config/gtk-3.0/settings.ini" <<'EOF_GTK3'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Inter 12
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF_GTK3
cat > "$HOME/.config/gtk-4.0/settings.ini" <<'EOF_GTK4'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-font-name=Inter 12
EOF_GTK4
for qt in qt5ct qt6ct; do
cat > "$HOME/.config/$qt/$qt.conf" <<'EOF_QT'
[Appearance]
icon_theme=Adwaita
style=kvantum
[Fonts]
fixed="JetBrainsMono Nerd Font Mono,12,-1,5,50,0,0,0,0,0"
general="Inter,12,-1,5,50,0,0,0,0,0"
EOF_QT
done

say "Configuring PipeWire user-session integration"
# Void's handbook recommends launching PipeWire as the logged-in user.
# WirePlumber and PulseAudio compatibility are enabled via config drop-ins.
if [[ -d /usr/share/examples/wireplumber ]]; then
  mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
  [[ -e "$HOME/.config/pipewire/pipewire.conf.d/10-wireplumber.conf" ]] || \\
    ln -s /usr/share/examples/wireplumber/10-wireplumber.conf "$HOME/.config/pipewire/pipewire.conf.d/10-wireplumber.conf"
fi
if [[ -d /usr/share/examples/pipewire ]]; then
  mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
  [[ -e "$HOME/.config/pipewire/pipewire.conf.d/20-pipewire-pulse.conf" ]] || \\
    ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf "$HOME/.config/pipewire/pipewire.conf.d/20-pipewire-pulse.conf"
fi
# Start PipeWire when Sway launches, only if not already running.
SWAY_AUTOSTART="$HOME/.config/theme/sway-autostart.conf"
mkdir -p "$HOME/.config/theme"
cat > "$SWAY_AUTOSTART" <<'EOF_PIPEWIRE'
# PipeWire user-session daemons
exec_always sh -c 'pgrep -x pipewire >/dev/null || pipewire'
exec_always sh -c 'pgrep -x wireplumber >/dev/null || wireplumber'
exec_always sh -c 'pgrep -x pipewire-pulse >/dev/null || pipewire-pulse'
EOF_PIPEWIRE
if [[ -f "$HOME/.config/sway/config" ]] && ! grep -Fq 'sway-autostart.conf' "$HOME/.config/sway/config"; then
  printf '\\n# User session services (PipeWire)\\ninclude ~/.config/theme/sway-autostart.conf\\n' >> "$HOME/.config/sway/config"
fi

say "Writing Kanagawa palette and application configs"
mkdir -p "$HOME/.config/theme" "$HOME/.config/kitty" "$HOME/.config/waybar" "$HOME/.config/sway"
cat > "$HOME/.config/theme/colors.sh" <<'EOF_COLORS'
# Kanagawa Wave palette
export BG="#1F1F28"
export BG_ALT="#2A2A37"
export FG="#DCD7BA"
export MUTED="#727169"
export RED="#C34043"
export ORANGE="#FFA066"
export YELLOW="#C0A36E"
export GREEN="#76946A"
export CYAN="#6A9589"
export BLUE="#7E9CD8"
export PURPLE="#957FB8"
export PINK="#D27E99"
EOF_COLORS

cat > "$HOME/.config/kitty/kanagawa.conf" <<'EOF_KITTY'
foreground #DCD7BA
background #1F1F28
selection_foreground #DCD7BA
selection_background #2D4F67
cursor #C8C093
cursor_text_color #1F1F28
color0 #16161D
color1 #C34043
color2 #76946A
color3 #C0A36E
color4 #7E9CD8
color5 #957FB8
color6 #6A9589
color7 #C8C093
color8 #727169
color9 #E82424
color10 #98BB6C
color11 #E6C384
color12 #7FB4CA
color13 #938AA9
color14 #7AA89F
color15 #DCD7BA
EOF_KITTY
touch "$HOME/.config/kitty/kitty.conf"
grep -Fq 'include kanagawa.conf' "$HOME/.config/kitty/kitty.conf" || printf '\n# Kanagawa theme\ninclude kanagawa.conf\n' >> "$HOME/.config/kitty/kitty.conf"

cat > "$HOME/.config/theme/sway-colors.conf" <<'EOF_SWAY'
# Kanagawa Sway colors
set $kanagawa_bg #1F1F28
set $kanagawa_bg1 #2A2A37
set $kanagawa_fg #DCD7BA
set $kanagawa_muted #727169
set $kanagawa_blue #7E9CD8
set $kanagawa_red #E46876
client.focused          $kanagawa_blue $kanagawa_bg $kanagawa_fg $kanagawa_blue $kanagawa_blue
client.focused_inactive $kanagawa_bg1 $kanagawa_bg1 $kanagawa_muted $kanagawa_bg1 $kanagawa_bg1
client.unfocused        $kanagawa_bg  $kanagawa_bg  $kanagawa_muted $kanagawa_bg  $kanagawa_bg
client.urgent           $kanagawa_red $kanagawa_red $kanagawa_fg $kanagawa_red $kanagawa_red
client.background       $kanagawa_bg
EOF_SWAY
if [[ -f "$HOME/.config/sway/config" ]] && ! grep -Fq 'include ~/.config/theme/sway-colors.conf' "$HOME/.config/sway/config"; then
  printf '\n# Kanagawa colors\ninclude ~/.config/theme/sway-colors.conf\n' >> "$HOME/.config/sway/config"
fi

cat > "$HOME/.config/waybar/kanagawa.css" <<'EOF_WAYBAR'
* { font-family: "Inter", "Noto Sans", sans-serif; font-size: 12px; border: none; border-radius: 0; min-height: 0; }
window#waybar { background: #1F1F28; color: #DCD7BA; }
#workspaces button { padding: 0 8px; color: #727169; background: transparent; }
#workspaces button.focused { color: #1F1F28; background: #7E9CD8; }
#workspaces button.urgent { color: #1F1F28; background: #E46876; }
#clock, #battery, #network, #pulseaudio, #tray { padding: 0 10px; background: #2A2A37; margin: 3px 2px; }
#battery.warning { color: #E6C384; }
#battery.critical, #network.disconnected { color: #E46876; }
EOF_WAYBAR
if [[ -f "$HOME/.config/waybar/style.css" ]] && ! grep -Fq 'kanagawa.css' "$HOME/.config/waybar/style.css"; then
  printf '@import url("kanagawa.css");\n' | cat - "$HOME/.config/waybar/style.css" > "$HOME/.config/waybar/style.css.tmp"
  mv "$HOME/.config/waybar/style.css.tmp" "$HOME/.config/waybar/style.css"
fi

say "Refreshing font cache and Sway"
fc-cache -f >/dev/null 2>&1 || true
swaymsg reload 2>/dev/null || true

cat <<'EOF_DONE'

Done. Please review these important Void-specific differences:
- Void uses runit; check /var/service and service names after installation.
- PipeWire is launched in your Sway user session; check its status with wpctl status.
- Screen-capture portal output/chooser settings need manual xdg-desktop-portal-wlr configuration.
- nix-ld is NixOS-specific. Use native Void packages, Distrobox/containers, or other compatibility methods for foreign binaries.
- Docker needs its service and permissions configured separately; Podman can run rootless.
- GTK settings set dark mode/fonts, not a full Kanagawa GTK theme. Kvantum needs a real Kanagawa Kvantum theme installed.
- Packages unavailable in enabled Void repositories are skipped. Review skipped package messages and install those manually (e.g. proprietary apps).
- Log out/in after changing locale, services, or environment variables.
EOF_DONE

