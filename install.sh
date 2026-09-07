#!/bin/bash

set -e  # Exit on error

echo "Starting system setup..."

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Installing packages..."
sudo pacman -S --noconfirm \
    zathura dunst btop waybar hypridle hyprlock hyprpaper hyprsunset wl-clipboard \
    grim slurp gimp qt5ct wev tmux brightnessctl cliphist dnsmasq vde2 ripgrep fd \
    fastfetch zsh pavucontrol zip unzip tree obs-studio audacity telegram-desktop \
    imv mpv noto-fonts-cjk python nodejs ttf-dejavu noto-fonts-emoji docker gdb fzf \
    docker-compose alsa-utils dnsutils distrobox cheese ncdu noto-fonts stow rofi \
    nasm pacman-contrib ttf-fira-code thunderbird neovim yazi imagemagick foot git \
    signal-desktop curl jdk-openjdk python base-devel nodejs npm opam ocaml

echo "Installing yay..."
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
else
    echo "yay already installed, skipping..."
fi

echo "Installing AUR packages..."
yay -S --noconfirm \
    ttf-jetbrains-mono-nerd \
    kanagawa-gtk-theme-git \
    kanagawa-icon-theme-git \
    anki resvg rofi-bluetooth-git \

echo "Creating directories..."
mkdir -p ~/projs
mkdir -p ~/docs
mkdir -p ~/pics/{walls,screenshots,webcam,backs,pfps}
mkdir -p ~/videos/OBS

echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

echo "Installing Zsh plugins..."
mkdir -p ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || echo "zsh-autosuggestions already exists"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || echo "zsh-syntax-highlighting already exists"

echo "Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust already installed, skipping..."
fi

echo "Stowing dotfiles..."
if [ -d "$HOME/dotfiles" ]; then
    cd "$HOME/dotfiles"
    stow -v \
        alacritty \
        dunst \
        git \
        gtk \
        fontconfig \
        hypr \
        imv \
        mime \
        mpv \
        nvim \
        rofi \
        swaylock \
        waybar \
        zathura \
        zsh \
        tmux \
        .local \
        glow \
        yazi
    cd -
else
    echo "WARNING: ~/dotfiles directory not found! Skipping stow..."
fi

echo "Configuring GTK theme, icons, and fonts..."
gsettings set org.gnome.desktop.interface gtk-theme 'Kanagawa-Yellow-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Kanagawa'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono Nerd Font 14'
echo "GTK settings applied!"

echo "Enabling services..."
sudo systemctl enable --now docker
sudo systemctl enable --now bluetooth
sudo systemctl enable --now tlp

echo "Adding user to docker group..."
sudo usermod -aG docker "$USER"

echo "Sourcing tmux..."
tmux source-file ~/.config/tmux.conf

echo "Configuring locale..."
sudo sed -i 's/^#\(en_GB.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=en_GB.UTF-8

echo "Configuring SSH..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "me@nezutero.dev" -f "$HOME/.ssh/id_ed25519" -N ""
else
    echo "SSH key already exists, skipping..."
fi

cat > "$HOME/.ssh/config" <<EOF
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF

chmod 600 "$HOME/.ssh/config"

echo "Setting Zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
else
    echo "Zsh is already the default shell."
fi

echo "============================================"
echo "Installation complete!"
echo "============================================"
echo "TODO:"
echo "- Log out and back in for docker group to take effect"
echo "- Open nvim and run :Lazy and :Mason"
echo "- Add your SSH key: https://github.com/settings/keys"
echo "============================================"
