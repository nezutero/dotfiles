# My dotfiles

**Warning**: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. I have many things that are specific to my setup and you may not want them.

## Installation

```sh
git clone https://github.com/nezutero/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

- This will install all the necessary packages and create folders. 
> WARNING: Only for Arch Linux and Arch-based distros. Also this is my personal stuff, so you might want to change the packages in the script. DO NOT RUN THIS SCRIPT IF YOU DON'T KNOW WHAT IT DOES.

```sh
chmod +x install.sh
./install.sh 
```

```sh
cp -r ~/.dotfiles/.config/* ~/.config
cp -r ~/.dotfiles/.local/bin/* ~/.local/bin
cp ~/.dotfiles/.gitconfig ~/.gitconfig
cp ~/.dotfiles/.zsh/.zshrc ~/.zshrc
```
