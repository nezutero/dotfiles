#!/bin/bash
# capture-system-config.sh
#
# Copies this machine's current, working system config files into your
# dotfiles repo, laid out for `stow -t /etc`. Run this once things are
# confirmed working, to freeze that state as the declared source of truth.
#
# Usage: ./capture-system-config.sh [path-to-dotfiles-repo]
#        (defaults to ~/dotfiles)

set -e
DOTFILES="${1:-$HOME/dotfiles}"
DEST="$DOTFILES/etc"

mkdir -p "$DEST"

cp_if_exists() {
    local src="$1"
    local rel="${src#/etc/}"
    local dst="$DEST/$rel"
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        sudo cp "$src" "$dst"
        sudo chown "$(id -u):$(id -g)" "$dst"
        echo "Captured $src -> ${dst#$HOME/}"
    else
        echo "Skipped $src (not found on this system)"
    fi
}

cp_if_exists /etc/mkinitcpio.conf
cp_if_exists /etc/mkinitcpio.d/linux.preset
cp_if_exists /etc/systemd/zram-generator.conf
cp_if_exists /etc/conf.d/snapper
cp_if_exists /etc/snapper/configs/root
cp_if_exists /etc/ly/config.ini
cp_if_exists /etc/default/grub
cp_if_exists /etc/fstab

echo ""
echo "============================================"
echo "Done. Review before committing:"
echo "  cd $DOTFILES && git status && git diff"
echo ""
echo "Note: /etc/default/grub's resume_offset= is tied to the CURRENT"
echo "swapfile. If you ever delete/recreate /swap/swapfile, recompute the"
echo "offset and update this file's GRUB_CMDLINE_LINUX before re-running"
echo "this capture — that one value doesn't survive a swapfile rebuild."
echo "============================================"
