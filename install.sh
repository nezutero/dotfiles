# install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install my fav nerd font: cascadia code
yay -S ttf-cascadia-code-nerd

# clone nvim config
git clone https://github.com/plastiey/nvim.git ~/.config/neovim

# install packer.nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# cd into dotfiles directory
cd ~/dotfiles

# create .config directories if they don't exist
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/btop
mkdir -p ~/.config/dunst
mkdir -p ~/.config/hypr
mkdir -p ~/.config/neofetch
mkdir -p ~/.config/ranger
mkdir -p ~/.config/rofi
mkdir -p ~/.config/waybar
mkdir -p ~/.config/zathura
mkdir -p ~/.config/nvim

# create .local/bin directories if they don't exist
mkdir -p ~/.local/bin

# create symlinks for .config directory
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

# create symlinks for other dotfiles
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
sudo ln -sf ~/.oh-my-zsh /root/.oh-my-zsh
sudo ln -sf ~/.config/nvim /root/.config/nvim
