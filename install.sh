#!/bin/bash

sudo pacman -Syu

sudo pacman -S --noconfirm \
    zathura dunst btop waybar hypridle hyprlock hyprpaper hyprsunset alacritty zen-browser ueberzugpp \
    wl-clipboard grim slurp npm pnpm yarn gimp qt5ct nwg-look wev tmux nextcloud lf android-udev \
    qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat android-tools thunar \
    fastfetch zsh materia-gtk-theme pavucontrol zip unzip tree obs-studio audacity telegram-desktop \
    imv mpv noto-fonts-cjk zig python nodejs ttf-dejavu noto-fonts-emoji kdenlive sof-firmware \
    zathura-pdf-mupdf docker docker-compose alsa-utils dnsutils distrobox bluez bluez-utils cheese \
    vesktop ncdu noto-fonts noto-fonts-cjk noto-fonts-emoji stow clipmenu tlp gdb chafa imagemagick \
    nasm speedcrunch spotify pacman-contrib github-cli ttf-fira-code foliate thunderbird

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

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

yay -S ttf-jetbrains-mono-nerd
yay -S gruvbox-dark-gtk gruvbox-plus-icon-theme
yay -S anki
yay -S resvg rofi-bluetooth-git

cd ~/dotfiles
stow alacritty dunst git gtk fontconfig hypr imv mime mpv nvim rofi swaylock waybar zathura zsh tmux .local glow
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
