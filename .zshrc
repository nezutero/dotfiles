# Environment variables
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="foot"
export BROWSER="zen-beta"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    fzf
    z
)

source "$ZSH/oh-my-zsh.sh"

# Plugins
source "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Shell aliases
alias q='exit'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias c='clear'

alias gtp='cd "$HOME/projs" && clear && ls -a'
alias gtd='cd "$HOME/dotfiles"'
alias gtn='cd "$HOME/notes"'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gcb='git checkout -b'
alias gco='git checkout'
alias gpl='git pull'
alias gps='git push'
alias gcl='git clone'
alias gbd='git branch -D'
alias gbs='git switch'

# Scripts
alias f='$HOME/dotfiles/scripts/fzfman.sh'
alias timer='$HOME/dotfiles/scripts/timer.sh'
export PATH="$HOME/.local/bin:$PATH"

# Mounting
alias mnt='udisksctl mount -b /dev/sda1'
alias umnt='udisksctl unmount -b /dev/sda1'

# USB
alias cdf='cd /run/media/nezutero/KINGSTON'

export BG="#1F1F28"
export BG_ALT="#2A2A37"
export FG="#DCD7BA"
export MUTED="#727169"
export RED="#C34043"
export ORANGE="#FFA066"
export YELLOW="#C0A36E"
export GREEN="#76946A"
export CYAN="#6A9589"
export BLUE="#7E9CD8"
export PURPLE="#957FB8"
export PINK="#D27E99"

export GTK_THEME=Adwaita:dark
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_STYLE_OVERRIDE=kvantum
