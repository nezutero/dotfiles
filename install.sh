#!/bin/bash

# update package repos
sudo pacman -Syu

# packages
sudo pacman -S --noconfirm \
    firefox git neovim zathura dunst btop waybar swaybg alacritty ranger rofi \
    telegram-desktop wl-clipboard grim slurp npm pnpm yarn gimp qt5ct lxappearance \
    neofetch zsh materia-gtk-theme nvidia nvidia-utils pavucontrol zip unzip tree \
    xf86-video-intel networkmanager lib32-nvidia-utils feh noto-fonts-cjk zig \
    python nodejs ttf-dejavu noto-fonts-emoji zathura-pdf-mupdf fzf docker docker-compose \
    alsa-utils

# yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# dir structure
mkdir -p ~/dev/mantain
mkdir -p ~/docs/{books,watashi}
mkdir -p ~/pics/{walls,screenshots,avatars,logos}
mkdir -p ~/vids/screencaptures
mkdir -p ~/.local/bin

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# cascadia code
yay -S ttf-cascadia-code-nerd

# nvim config
git clone https://github.com/kenjitheman/nvim.git ~/.config/neovim

# packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# spotify
yay -S spotify
