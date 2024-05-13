#!/bin/bash

sudo pacman -Syu

sudo pacman -S --noconfirm \
    firefox-developer-edition chromium git neovim zathura dunst btop waybar swaybg alacritty ranger rofi \
    telegram-desktop wl-clipboard grim slurp npm pnpm yarn gimp qt5ct lxappearance \
    neofetch zsh materia-gtk-theme nvidia nvidia-utils pavucontrol zip unzip tree \
    xf86-video-intel networkmanager lib32-nvidia-utils feh noto-fonts-cjk zig \
    python nodejs ttf-dejavu noto-fonts-emoji zathura-pdf-mupdf fzf docker docker-compose \
    alsa-utils reaper audacity dnsutils

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

mkdir -p ~/dev/mantain
mkdir -p ~/docs/{books,watashi}
mkdir -p ~/pics/{walls,screenshots,avatars,logos}
mkdir -p ~/vids/screencaptures
mkdir -p ~/.local/bin

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

yay -S ttf-cascadia-code-nerd

git clone https://github.com/kenjitheman/nvim.git ~/.config/neovim

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

yay -S spotify video-downloader vesktop spicefy-cli wlogout

git clone --depth=1 https://github.com/spicetify/spicetify-themes.git 
cd spicetify-themes
cp -r * ~/.config/spicetify/Themes
spicetify config current_theme Sleek
spicetify config color_scheme UltraBlack
spicetify config custom_apps new-releases
spicetify config custom_apps lyrics-plus
spicetify config custom_apps lyrics-plus
spicetify apply
