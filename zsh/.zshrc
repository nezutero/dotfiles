# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export HOME="/home/nezutero"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="$PATH:/$HOME/go/bin"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.npm/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/npm/bin:$PATH"
export PATH="$HOME/.local/share/cargo/bin:$PATH"
export PATH="$HOME/.local/share/go/bin:$PATH"
export PATH="$HOME/.local/share/rustup/bin:$PATH"

# User configuration

# Oh My Zsh configuration
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nvim"
else
  export EDITOR="nvim"
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias q="exit"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

alias c="clear"
alias gtp="$HOME/projs && clear && ls -a"
alias gtd="cd $HOME/dotfiles"
alias gtc="cd $HOME/.config"
alias gtn="cd $HOME/notes"

alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gcb="git checkout -b"
alias gco="git checkout"
alias gpl="git pull"
alias gps="git push"
alias gcl="git clone"
alias gbd="git branch -D"
alias gbs="git switch"

alias mnt="udisksctl mount -b /dev/sda1"
alias umnt="udisksctl unmount -b /dev/sda1"
alias cdf="cd /run/media/nezutero/KINGSTON"

alias readmd="glow"
alias f="fzf"

export EDITOR="nvim"
export GIT_EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="alacritty"
export BROWSER="zen-browser"
export FILE_EXPLORER="yazi"
export FILE_MANAGER="yazi"
export VIDEO_PLAYER="mpv"
export SCREENCAST_TOOL="obs"
export PDF_VIEWER="zathura"
export IMAGE_VIEWER="imv"
