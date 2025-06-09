#!/bin/bash

sudo pacman -Syu

sudo pacman -S --noconfirm \
    zathura dunst btop waybar hypridle hyprlock hyprpaper alacrit zen-browser chromium \
    telegram-desktop wl-clipboard grim slurp npm pnpm yarn gimp qt5ct nwg-look wev tmux \
    fastfetch zsh materia-gtk-theme pavucontrol zip unzip tree obs-studio audacity steam \
    imv mpv noto-fonts-cjk zig python nodejs ttf-dejavu noto-fonts-emoji kdenlive sof-firmware \
    zathura-pdf-mupdf docker docker-compose alsa-utils dnsutils distrobox bluez bluez-utils cheese \
    vesktop video-downloader ncdu noto-fonts noto-fonts-cjk noto-fonts-emoji stow clipmenu tlp gdb nasm

sudo systemctl enable tlp.service
sudo systemctl enable --now tlp

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

mkdir -p ~/dev
mkdir -p ~/Documents/{Books, Docs}
mkdir -p ~/Pictures/{walls,screenshots,Webcam,backs}
mkdir -p ~/Videos/{OBS,Webcam}

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}plugins/zsh-vi-mode

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

yay -S ttf-jetbrains-mono-nerd
yay -S gruvbox-dark-gtk gruvbox-plus-icon-theme
yay -S ncspot

sudo pacman -S yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick
yay -S resvg rofi-bluetooth-git

cd ~/dotfiles
stow alacritty dunst chromium git gtk fontconfig hypr imv mime mpv nvim rofi swaylock waybar zathura zsh tmux .local glow
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
