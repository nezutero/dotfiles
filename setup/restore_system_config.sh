#!/bin/bash
# restore-system-config.sh
#
# Symlinks captured system configs from your dotfiles repo into /etc via
# GNU Stow. Run this on a fresh install, BEFORE the imperative setup
# scripts — they assume these files are already in place and no longer
# write config content themselves.
#
# Usage: ./restore-system-config.sh [path-to-dotfiles-repo]
#        (defaults to ~/dotfiles)

set -e
DOTFILES="${1:-$HOME/dotfiles}"

sudo pacman -S --noconfirm --needed stow

if [ ! -d "$DOTFILES/etc" ]; then
    echo "No $DOTFILES/etc found — nothing captured yet. Run"
    echo "capture-system-config.sh on a working system first."
    exit 1
fi

# Stow refuses to symlink over a real (non-symlink) file. The base linux
# and grub packages ship their own defaults at these paths, so back those
# up before handing the paths to stow.
MANAGED_FILES=(
    /etc/mkinitcpio.conf
    /etc/mkinitcpio.d/linux.preset
    /etc/systemd/zram-generator.conf
    /etc/conf.d/snapper
    /etc/snapper/configs/root
    /etc/ly/config.ini
    /etc/default/grub
    /etc/fstab
)

for f in "${MANAGED_FILES[@]}"; do
    rel="${f#/etc/}"
    if [ -f "$DOTFILES/etc/$rel" ] && [ -e "$f" ] && [ ! -L "$f" ]; then
        sudo mv "$f" "$f.pacsave"
        echo "Backed up existing $f -> $f.pacsave"
    fi
done

sudo stow -d "$DOTFILES" -t /etc etc

echo ""
echo "Restored. Verify with:"
echo "  ls -la /etc/mkinitcpio.conf /etc/default/grub /etc/fstab"
echo "(should show symlinks pointing back into $DOTFILES/etc/...)"
