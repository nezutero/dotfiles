#!/bin/bash

# update package repos
sudo pacman -Syu

# install packages from official repos
sudo pacman -S --noconfirm \
    firefox git neovim zathura dunst btop waybar swaybg alacritty ranger rofi \
    telegram-desktop discord wl-clipboard grim slurp npm pnpm yarn gimp qt5ct lxappearance \
    neofetch zsh materia-gtk-theme nvidia nvidia-utils pavucontrol zip unzip tree \
    xf86-video-intel networkmanager lib32-nvidia-utils feh noto-fonts-cjk zig \
    python nodejs ttf-dejavu noto-fonts-emoji zathura-pdf-mupdf fzf docker docker-compose \
    alsa-utils

# install Yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# create dir structure
mkdir -p ~/projs/mantain
mkdir -p ~/docs/{books,watashi}
mkdir -p ~/pics/{walls,screenshots,avatars,logos}
mkdir -p ~/vids/screencaptures
mkdir -p ~/.local/bin

# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install my fav nerd font: cascadia code
yay -S ttf-cascadia-code-nerd

# clone nvim config
git clone https://github.com/kenjitheman/nvim.git ~/.config/neovim

# install packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# cd ~/dotfiles and crete symlinks for dotfiles
# cd into dotfiles directory
cd ~/dotfiles

# cd into dotfiles directory
cd ~/dotfiles

# Create symlinks for .config directory
ln -sf ~/.dotfiles/.config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -sf ~/.dotfiles/.config/btop/btop.conf ~/.config/btop/btop.conf
ln -sf ~/.dotfiles/.config/dunst/dunstrc ~/.config/dunst/dunstrc
ln -sf ~/.dotfiles/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -sf ~/.dotfiles/.config/neofetch/config.conf ~/.config/neofetch/config.conf
ln -sf ~/.dotfiles/.config/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf ~/.dotfiles/.config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -sf ~/.dotfiles/.config/waybar/config ~/.config/waybar/config
ln -sf ~/.dotfiles/.config/waybar/style.css ~/.config/waybar/style.css
ln -sf ~/.dotfiles/.config/zathura/zathurarc ~/.config/zathura/zathurarc

# Create symlinks for other dotfiles
ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/.dotfiles/install.sh ~/install.sh
ln -sf ~/.dotfiles/.local/bin/chman-commands ~/.local/bin/chman-commands
ln -sf ~/.dotfiles/.local/bin/chman-langs ~/.local/bin/chman-langs
ln -sf ~/.dotfiles/.local/bin/chman.sh ~/.local/bin/chman.sh
ln -sf ~/.dotfiles/.local/bin/fzfman.sh ~/.local/bin/fzfman.sh
ln -sf ~/.dotfiles/.zshrc ~/.zshrc

# create symlinks for root -> home
sudo mkdir -p /root/.config
sudo ln -sf ~/.dotfiles/.zshrc /root/.zshrc
sudo ln -sf ~/.config/.oh-my-zsh /root/.oh-my-zsh
sudo ln -sf ~/.config/nvim /root/.config/nvim
