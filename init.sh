#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -ne 0 ]] || { echo "Run as regular user, not root."; exit 1; }
command -v sudo >/dev/null || { echo "Install/configure sudo first."; exit 1; }

USER_NAME="${USER:-$(id -un)}"
TIMEZONE="Europe/Paris"
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

say() { printf "\n==> %s\n" "$*"; }

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
  else
    echo "Skipping missing service: $s"
  fi
}

link_config() {
  local source="$1" target="$2"
  [[ -e "$source" ]] || { echo "Missing dotfile: $source"; return 0; }
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.backup.$(date +%s)"
  fi
  ln -sfn "$source" "$target"
}

say "Updating repositories"
sudo xbps-install -S

say "Installing packages"
install_available 
  zsh git wget bind-utils jq fzf fd tree ncdu btop fastfetch killall zip unzip yazi zbar imagemagick 
  gnupg pass tmux gcc gdb glibc-devel go rust nodejs python3 openjdk21 
  podman docker distrobox qemu pandoc typst zathura 
  fontconfig noto-fonts-ttf noto-fonts-cjk noto-fonts-emoji nerd-fonts adwaita-icon-theme 
  dbus elogind polkit NetworkManager udisks2 gvfs 
  sway swayidle swaybg swaylock wlsunset waybar foot kitty rofi dunst libnotify 
  cliphist wl-clipboard grim slurp wtype wev brightnessctl pavucontrol 
  xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk 
  qt5ct qt6ct kvantum gtk+3 gtk4 gsettings-desktop-schemas 
  clang make cmake pkg-config cargo jdk21 vscodium android-tools 
  imv mpv obs thunderbird telegram-desktop signal-desktop 
  pam-devel libxcb-devel xorg xorg-xauth ncurses

say "Enabling services"
for service in dbus elogind polkitd NetworkManager udisksd; do
  enable_service "$service"
done

say "Installing Ly"
if [[ ! -d /etc/sv/ly-runit-service ]]; then
  if [[ ! -d /tmp/ly-runit ]]; then
    git clone --recurse-submodules https://github.com/EdenQwQ/ly-runit.git /tmp/ly-runit
  fi

  (
    cd /tmp/ly-runit
    make
    sudo make install
  )
fi

if [[ -d /etc/sv/ly-runit-service ]]; then
  sudo ln -snf /etc/sv/ly-runit-service /var/service/ly
elif [[ -d /etc/sv/ly ]]; then
  sudo ln -snf /etc/sv/ly /var/service/ly
else
  echo "ERROR: Ly runit service was not installed."
  exit 1
fi

if [[ -d /etc/sv/agetty-tty2 ]]; then
  sudo touch /etc/sv/agetty-tty2/down
  sudo rm -f /var/service/agetty-tty2
fi

say "Setting timezone and locales"
if [[ -e "/usr/share/zoneinfo/$TIMEZONE" ]]; then
  sudo ln -snf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
  echo "$TIMEZONE" | sudo tee /etc/timezone >/dev/null
fi

if [[ -f /etc/default/libc-locales ]]; then
  sudo cp -a /etc/default/libc-locales "/etc/default/libc-locales.bak.$(date +%s)"
  sudo sed -i 
    -e 's/^#\?en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' 
    -e 's/^#\?en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' 
    -e 's/^#\?fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' 
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
if [[ -x /usr/bin/zsh ]]; then
  sudo chsh -s /usr/bin/zsh "$USER_NAME" || true
fi

for group in wheel network kvm; do
  getent group "$group" >/dev/null && sudo usermod -aG "$group" "$USER_NAME" || true
done

say "Configuring NetworkManager"
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/10-dns.conf >/dev/null <<'EOF_NM'
[main]
dns=default
EOF_NM

say "Linking dotfiles"
mkdir -p "$CONFIG_DIR"

for name in dunst fastfetch foot git nvim rofi sway swaylock tmux waybar yazi zathura; do
  link_config "$DOTFILES_DIR/$name" "$CONFIG_DIR/$name"
done

link_config "$DOTFILES_DIR/fontconfig" "$CONFIG_DIR/fontconfig"
link_config "$DOTFILES_DIR/gtk-3.0/setting.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
link_config "$DOTFILES_DIR/gtk-4.0/setting.ini" "$CONFIG_DIR/gtk-4.0/settings.ini"
link_config "$DOTFILES_DIR/mimeapps.list" "$CONFIG_DIR/mimeapps.list"

say "Linking TLP config"
if [[ -f "$DOTFILES_DIR/etc/tlp.conf" ]]; then
  sudo mkdir -p /etc
  if [[ -e /etc/tlp.conf && ! -L /etc/tlp.conf ]]; then
    sudo mv /etc/tlp.conf "/etc/tlp.conf.backup.$(date +%s)"
  fi
  sudo ln -sfn "$DOTFILES_DIR/etc/tlp.conf" /etc/tlp.conf
fi

say "Configuring environment"
mkdir -p "$CONFIG_DIR/environment.d"

cat > "$CONFIG_DIR/environment.d/90-desktop.conf" <<'EOF_ENV'
XCURSOR_THEME=Adwaita
XCURSOR_SIZE=24
PASSWORD_STORE_ENABLE_EXTENSIONS=true
MOZ_ENABLE_WAYLAND=1
GTK_THEME=Adwaita:dark
QT_QPA_PLATFORM=wayland
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=kvantum
EOF_ENV

touch "$HOME/.zprofile"

if ! grep -q 'environment.d/90-desktop.conf' "$HOME/.zprofile"; then
  cat >> "$HOME/.zprofile" <<'EOF_ZPROFILE'

if [[ -r "$HOME/.config/environment.d/90-desktop.conf" ]]; then
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    export "$key=$value"
  done < "$HOME/.config/environment.d/90-desktop.conf"
fi
EOF_ZPROFILE
fi

say "Refreshing font cache"
fc-cache -f >/dev/null 2>&1 || true

printf '\nSetup complete. Log out and reboot to test Ly.\n'
