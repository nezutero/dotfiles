#!/bin/bash
set -e  # Exit on error

echo "Starting system setup..."

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Installing packages..."
sudo pacman -S --noconfirm \
    zathura dunst btop waybar hypridle hyprlock hyprpaper hyprsunset alacritty \
    wl-clipboard grim slurp npm pnpm yarn gimp qt5ct nwg-look wev tmux brightnessctl cliphist \
    qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat thunar ripgrep fd glow \
    fastfetch zsh materia-gtk-theme pavucontrol zip unzip tree obs-studio audacity telegram-desktop \
    imv mpv noto-fonts-cjk zig python nodejs ttf-dejavu noto-fonts-emoji sof-firmware \
    docker docker-compose alsa-utils dnsutils distrobox bluez bluez-utils cheese \
    ncdu noto-fonts stow rofi \
    nasm speedcrunch pacman-contrib ttf-fira-code thunderbird \
    neovim yazi imagemagick chafa \
    gdb bat eza fzf

echo "Installing yay..."
if ! command -v yay &> /dev/null; then
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
    gruvbox-material-gtk-theme-git \
    gruvbox-plus-icon-theme \
    anki \
    resvg \
    rofi-bluetooth-git \
    helix-browser-bin

echo "Creating directories..."
mkdir -p ~/projs
mkdir -p ~/Documents/{Books,Docs}
mkdir -p ~/Pictures/{walls,screenshots,Webcam,backs}
mkdir -p ~/Videos/{OBS,Webcam}
mkdir -p ~/.config

echo "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi

echo "Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>/dev/null || echo "zsh-autosuggestions already exists"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>/dev/null || echo "zsh-syntax-highlighting already exists"

echo "Installing Rust..."
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "Rust already installed, skipping..."
fi

echo "Installing tmux plugin manager..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "TPM already installed, skipping..."
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

echo "Enabling services..."
sudo systemctl enable --now docker
sudo systemctl enable --now bluetooth
sudo systemctl enable --now tlp

echo "Adding user to docker group..."
sudo usermod -aG docker "$USER"

echo "============================================"
echo "Installation complete!"
echo "============================================"
echo "TODO:"
echo "1. Log out and back in for docker group to take effect"
echo "2. Run 'tmux' and press prefix + I to install tmux plugins"
echo "3. Open nvim and run :Lazy and :Mason"
echo "4. Change default shell: chsh -s /bin/zsh"
echo "============================================"
