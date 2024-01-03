#!/bin/bash

# install yay | AUR helper
sudo pacman -Syu --noconfirm yay

# install essential packages
sudo pacman -Syu --noconfirm alacritty bspwm rofi dunst neofetch polybar ranger sxhkd tmux zsh neovim firefox pavucontrol gimp obs-studio xorg xorg-xinit xorg-xrandr xorg-xsetroot fzf gcc g++

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# clone dotfiles repository
git clone https://github.com/kenjitheman/dotfiles.git ~/dotfiles

# symlink config files
ln -sf ~/dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
ln -sf ~/dotfiles/bspwm/bspwmrc ~/.config/bspwm/bspwmrc
ln -sf ~/dotfiles/dunst/dunstrc ~/.config/dunst/dunstrc
ln -sf ~/dotfiles/neofetch/config.conf ~/.config/neofetch/config.conf
ln -sf ~/dotfiles/polybar/config ~/.config/polybar/config
ln -sf ~/dotfiles/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf ~/dotfiles/sxhkd/sxhkdrc ~/.config/sxhkd/sxhkdrc
ln -sf ~/dotfiles/.config/gtk-2.0 ~/.config/gtk-2.0
ln -sf ~/dotfiles/.config/gtk-3.0 ~/.config/gtk-3.0
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.xinitrc ~/.xinitrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.config/rofi ~/.config/rofi

yay -S --noconfirm materia-gtk-theme

# create dirs
mkdir -p ~/docs 
mkdir -p ~/downloads
mkdir -p ~/pics
mkdir -p ~/vids
mkdir -p ~/projs/maintenance
mkdir -p ~/bin

# symlink scripts
ln -sf ~/dotfiles/bin/chtman.sh ~/bin/chtman.sh
ln -sf ~/dotfiles/bin/fzfman.sh ~/bin/fzfman.sh
ln -sf ~/dotfiles/bin/chtman-langs ~/bin/chtman-langs
ln -sf ~/dotfiles/bin/chtman-commands ~/bin/chtman-commands

# install cht.sh
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh

# set zsh as default shell
chsh -s /bin/zsh

# install nerd font that is in ~/dotfiles/.local/share/fonts
fc-cache -fv ~/.local/share/fonts

# clone nvim config
git clone https://github.com/kenjitheman/nvim.lua.git ~/.config/nvim

# install packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# additional configs
gsettings set org.gnome.desktop.interface monospace-font-name 'CaskaydiaCove Nerd Font'
gsettings set org.gnome.desktop.interface font-name 'CaskaydiaCove Nerd Font'

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install js stuff
sudo pacman -Syu --noconfirm nodejs npm yarn nvm

# install bun
curl -fsSL https://bun.sh/install | bash

# install python stuff
sudo pacman -Syu --noconfirm python python-pip

# clone firefox user.js
git clone https://github.com/kenjitheman/some_confs.git ~/some_confs && cp ~/some_confs/user.js ~/.mozilla/firefox/*.default-release/user.js 
&& rm -rf ~/some_confs

echo "Installation complete. Please restart your session to apply changes."
