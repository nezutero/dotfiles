#!/usr/bin/env bash
#
# init.sh - bootstrap a fresh Void Linux install from this dotfiles repo.
#
# Run as your normal user (not root) after the first boot:   ./init.sh
# It uses sudo where it needs root and is safe to run again.
#
# Optional environment:
#   SWAPFILE_GB=17    size of the fallback swapfile in GiB (0 = don't create one)
#   ZRAM_PERCENT=50   zram size as a percentage of RAM
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
ME="$(id -un)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
SWAPFILE_GB="${SWAPFILE_GB:-17}"
ZRAM_PERCENT="${ZRAM_PERCENT:-50}"
SV_DIR=/var/service
MISSING=()

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Symlinks (the part that replaces GNU Stow)
# ---------------------------------------------------------------------------

# link SRC DST: make DST a symlink to SRC.
#  - already the right link: nothing to do
#  - DST exists as a real file/dir or a different link: moved to $BACKUP first,
#    so `ln -s` always creates a fresh link and nothing is ever overwritten
link() {
  local src=$1 dst=$2
  if [[ ! -e $src ]]; then
    warn "not found, skipping: $src"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [[ -L $dst && "$(readlink -- "$dst")" == "$src" ]]; then
    return 0
  fi
  if [[ -e $dst || -L $dst ]]; then
    mkdir -p "$BACKUP"
    mv -- "$dst" "$BACKUP/$(printf '%s' "${dst#/}" | tr / _)"
    warn "existing $dst moved to $BACKUP"
  fi
  ln -s -- "$src" "$dst"
  printf '  %s -> %s\n' "$dst" "$src"
}

# cfg REPO_PATH [CONFIG_PATH]: link $DOTFILES/REPO_PATH to ~/.config/CONFIG_PATH
# (same relative path unless a second argument says otherwise)
cfg() { link "$DOTFILES/$1" "$CONFIG/${2:-$1}"; }

# Zen keeps its profile outside ~/.config, and Void has no Zen package.
# Install it first (tarball from the Zen releases page), start it once so the
# profile exists, then run this script again.
link_zen() {
  local profile found=0
  for profile in "$HOME"/.zen/*Default*/; do
    [[ -d $profile ]] || continue
    link "$DOTFILES/zen/chrome"  "${profile}chrome"
    link "$DOTFILES/zen/user.js" "${profile}user.js"
    found=1
  done
  if (( ! found )); then
    warn "no Zen profile in ~/.zen yet: start Zen once, then re-run init.sh"
  fi
}

write_wlr_portal_config() {
  mkdir -p "$DOTFILES/xdg-desktop-portal-wlr"
  cat >"$DOTFILES/xdg-desktop-portal-wlr/config" <<'EOF'
[screencast]
output_name=eDP-1
chooser_type=none
EOF
  log "created xdg-desktop-portal-wlr/config in the repo (screen sharing always uses eDP-1, no picker): commit it"
}

link_dotfiles() {
  log "Linking dotfiles from $DOTFILES"
  cfg dunst/dunstrc
  cfg fastfetch/config.jsonc
  cfg fontconfig/fonts.conf
  cfg foot/foot.ini
  cfg git/config
  # the repo spells these "setting.ini"; GTK only reads "settings.ini"
  cfg gtk-3.0/setting.ini gtk-3.0/settings.ini
  cfg gtk-4.0/setting.ini gtk-4.0/settings.ini
  cfg mimeapps.list
  cfg nvim
  cfg rofi/config.rasi
  cfg rofi/theme.rasi
  cfg sway/config
  cfg swaylock/config
  cfg tmux/tmux.conf
  cfg waybar/config.jsonc
  cfg waybar/style.css
  cfg yazi/yazi.toml
  cfg zathura/zathurarc

  if [[ ! -e $DOTFILES/xdg-desktop-portal-wlr/config ]]; then
    write_wlr_portal_config
  fi
  cfg xdg-desktop-portal-wlr/config

  # PipeWire: let pipewire itself launch wireplumber and the PulseAudio shim
  # (the per-user setup from the Void handbook)
  link /usr/share/examples/wireplumber/10-wireplumber.conf \
       "$CONFIG/pipewire/pipewire.conf.d/10-wireplumber.conf"
  link /usr/share/examples/pipewire/20-pipewire-pulse.conf \
       "$CONFIG/pipewire/pipewire.conf.d/20-pipewire-pulse.conf"

  link_zen
}

# ---------------------------------------------------------------------------
# Packages (xbps)
# ---------------------------------------------------------------------------

pkg_exists() { xbps-query -R "$1" >/dev/null 2>&1; }

# install_pkgs a b c: install every package that exists in the repos and
# remember the ones that don't, so one wrong name doesn't abort the run
install_pkgs() {
  local ok=() p
  for p in "$@"; do
    if pkg_exists "$p"; then
      ok+=("$p")
    else
      MISSING+=("$p")
    fi
  done
  if (( ${#ok[@]} )); then
    sudo xbps-install -y "${ok[@]}"
  fi
}

# install_any a b c: install the first candidate that exists (for names that
# differ between repos or releases)
install_any() {
  local p
  for p in "$@"; do
    if pkg_exists "$p"; then
      sudo xbps-install -y "$p"
      return 0
    fi
  done
  MISSING+=("$(IFS='|'; echo "$*")")
}

install_all_packages() {
  log "Updating the system"
  sudo xbps-install -Syu xbps   # xbps has to be current before a full upgrade
  sudo xbps-install -yu

  log "Installing packages"

  # Session plumbing that NixOS did for you (dbus, logind, audio, portals, ...)
  install_pkgs \
    dbus elogind polkit NetworkManager chrony tlp mesa-dri \
    pipewire pulseaudio-utils \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    xorg-server-xwayland udisks2 gvfs

  # Desktop (Sway); ly replaces tuigreet
  install_pkgs \
    sway swayidle swaybg swaylock wlsunset ly foot foot-terminfo dunst libnotify \
    cliphist wl-clipboard grim slurp wtype wev brightnessctl pavucontrol \
    adwaita-icon-theme noto-fonts-ttf noto-fonts-emoji noto-fonts-cjk
  install_any Waybar waybar
  install_any rofi-wayland rofi
  install_any font-jetbrains-mono font-jetbrains-mono-ttf

  # Command line
  install_pkgs \
    zsh tmux git curl wget bind-utils jq fzf fd ripgrep tree ncdu btop fastfetch \
    psmisc zip unzip yazi zbar ImageMagick pass pass-otp gnupg neovim
  install_any pinentry-gnome pinentry-gnome3 pinentry-gtk

  # Programming
  install_pkgs \
    base-devel glibc-devel gcc gdb go rust cargo nodejs python3 openjdk21 android-tools

  # Containers and VMs (the docker daemon isn't enabled, same as on NixOS)
  install_pkgs podman docker distrobox qemu

  # Documents
  install_pkgs pandoc typst zathura zathura-pdf-mupdf \
    libreoffice-writer libreoffice-calc libreoffice-impress   # instead of OnlyOffice

  # Media and messaging. Some of these are probably not in the Void repos;
  # anything missing is listed at the end.
  install_pkgs imv mpv obs-studio drawy thunderbird telegram-desktop \
    torbrowser-launcher signal-desktop vscodium
}

# ---------------------------------------------------------------------------
# System configuration
# ---------------------------------------------------------------------------

# ly lists the .desktop files in /usr/share/wayland-sessions. Sway needs a
# D-Bus *session* bus (dunst, portals, pipewire all want one). On NixOS systemd
# provided it; here a tiny wrapper starts sway inside dbus-run-session.
install_sway_session() {
  sudo tee /usr/local/bin/sway-session >/dev/null <<'EOF'
#!/bin/sh
exec dbus-run-session -- sway "$@"
EOF
  sudo chmod 755 /usr/local/bin/sway-session
  sudo tee /usr/share/wayland-sessions/sway-dbus.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway (D-Bus)
Comment=Sway inside dbus-run-session
Exec=/usr/local/bin/sway-session
Type=Application
DesktopNames=sway
EOF
}

configure_user() {
  local g
  for g in audio video kvm network; do
    if getent group "$g" >/dev/null; then
      sudo usermod -aG "$g" "$ME"
    fi
  done
  # rootless podman needs subuid/subgid ranges (NixOS assigned them for you)
  if ! grep -q "^$ME:" /etc/subuid 2>/dev/null; then
    sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$ME"
  fi
  if [[ "$(getent passwd "$ME" | cut -d: -f7)" != */zsh ]]; then
    sudo chsh -s /bin/zsh "$ME"
  fi
}

# zram swap (RAM first), then the swapfile as fallback, same idea as the NixOS
# config. zramen reads its settings from /etc/sv/zramen/conf.
setup_zram() {
  if [[ ! -d /etc/sv/zramen ]]; then
    warn "zramen service not found, skipping zram"
    return 0
  fi
  sudo tee /etc/sv/zramen/conf >/dev/null <<EOF
# written by init.sh
export ZRAM_COMP_ALGORITHM=zstd
export ZRAM_SIZE=$ZRAM_PERCENT
export ZRAM_PRIORITY=100
EOF
}

setup_swapfile() {
  local f=/swapfile
  if (( SWAPFILE_GB <= 0 )); then
    return 0
  fi
  if [[ ! -f $f ]]; then
    log "Creating ${SWAPFILE_GB}G swapfile (inside the encrypted root)"
    sudo fallocate -l "${SWAPFILE_GB}G" "$f" \
      || sudo dd if=/dev/zero of="$f" bs=1M count=$((SWAPFILE_GB * 1024)) status=progress
    sudo chmod 600 "$f"
    sudo mkswap "$f"
  fi
  if ! grep -q "^$f " /etc/fstab; then
    echo "$f none swap defaults,pri=10 0 0" | sudo tee -a /etc/fstab >/dev/null
  fi
  sudo swapon -a
}

configure_system() {
  log "Configuring the system"
  # TLP's config is copied, not linked: root shouldn't read its config from a
  # directory the user can write to.
  if [[ -f $DOTFILES/etc/tlp.conf ]] && ! sudo cmp -s "$DOTFILES/etc/tlp.conf" /etc/tlp.conf; then
    sudo install -Dm644 "$DOTFILES/etc/tlp.conf" /etc/tlp.conf
  fi
  install_sway_session
  configure_user
  setup_zram
  setup_swapfile
}

check_sway_config() {
  local f="$DOTFILES/sway/config"
  [[ -f $f ]] || return 0
  grep -Eq '^[[:space:]]*exec(_always)?[[:space:]].*pipewire' "$f" \
    || warn "sway/config: add 'exec pipewire' (it launches wireplumber and pipewire-pulse through the conf.d links)"
  grep -q 'dbus-update-activation-environment' "$f" \
    || warn "sway/config: add 'exec dbus-update-activation-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway' (portals and screen sharing need it)"
}

# ---------------------------------------------------------------------------
# runit services: enabling one = symlinking /etc/sv/NAME into /var/service
# ---------------------------------------------------------------------------

enable_service() {
  local s=$1
  if [[ ! -d /etc/sv/$s ]]; then
    warn "no /etc/sv/$s (package missing?), skipping"
    return 0
  fi
  if [[ ! -e $SV_DIR/$s ]]; then
    sudo ln -s "/etc/sv/$s" "$SV_DIR/$s"
  fi
}

disable_service() {
  if [[ -e $SV_DIR/$1 ]]; then
    sudo rm -f "$SV_DIR/$1"
  fi
}

# Last on purpose: switching to NetworkManager can drop the connection.
enable_services() {
  log "Enabling runit services"
  local s
  # NetworkManager replaces dhcpcd/wpa_supplicant; ly takes over tty2
  for s in dhcpcd wpa_supplicant agetty-tty2; do
    disable_service "$s"
  done
  for s in dbus elogind NetworkManager chronyd tlp zramen ly; do
    enable_service "$s"
  done
}

summary() {
  echo
  if (( ${#MISSING[@]} )); then
    warn "Not found in the Void repos (install another way, or drop them):"
    printf '    %s\n' "${MISSING[@]}" >&2
  fi
  if command -v nvim >/dev/null; then
    log "$(nvim --version | head -n1)  (your config uses vim.pack, which needs 0.12+)"
  fi
  log "Done. Reboot, then pick \"Sway (D-Bus)\" in ly."
}

main() {
  if [[ $EUID -eq 0 ]]; then
    echo "Run this as your normal user, not root (it uses sudo where needed)." >&2
    exit 1
  fi
  install_all_packages
  link_dotfiles
  configure_system
  check_sway_config
  enable_services
  summary
}

# Only run when executed, so the functions can be sourced and tested.
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
