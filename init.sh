#!/usr/bin/env bash
set -euo pipefail

GIT_USER="nezutero"
DOTFILES_GIT="https://codeberg.org/${GIT_USER}/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_ETC_NIXOS="/etc/nixos.bak"

if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "Skipping clone: $DOTFILES_DIR already exists"
elif [ -e "$DOTFILES_DIR" ]; then
  echo "Error: $DOTFILES_DIR exists but is not a Git repository"
  exit 1
else
  echo "Cloning dotfiles..."
  git clone "$DOTFILES_GIT" "$DOTFILES_DIR"
fi

if [ -L /etc/nixos ]; then
  CURRENT_TARGET="$(readlink /etc/nixos)"

  if [ "$CURRENT_TARGET" = "$DOTFILES_DIR" ]; then
    echo "/etc/nixos already points to $DOTFILES_DIR"
  else
    echo "/etc/nixos points to $CURRENT_TARGET"
    sudo rm /etc/nixos
    sudo ln -s "$DOTFILES_DIR" /etc/nixos
  fi

elif [ -e /etc/nixos ]; then
  echo "Backing up existing /etc/nixos to $BACKUP_ETC_NIXOS"
  sudo mv /etc/nixos "$BACKUP_ETC_NIXOS"
  sudo ln -s "$DOTFILES_DIR" /etc/nixos

else
  sudo ln -s "$DOTFILES_DIR" /etc/nixos
fi

echo "Running: sudo nixos-rebuild switch"
sudo nixos-rebuild switch --flake .

if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo
  echo "=== SSH public key ==="
  cat "$HOME/.ssh/id_ed25519.pub"
  echo "======================"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo
  echo "=== SSH public key ==="
  cat "$HOME/.ssh/id_rsa.pub"
  echo "======================"
else
  echo "No SSH public key found at ~/.ssh/*.pub"
fi

echo
read -r -p "Add the SSH key to your Git hosting, then press Enter to continue (Ctrl+C to abort)..."

# switch dotfiles remote from HTTPS to SSH
set -x

git -C "$DOTFILES_DIR" remote set-url origin "git@codeberg.org:${GIT_USER}/dotfiles.git"

set +x

echo "Done."
