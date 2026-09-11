#!/bin/bash
# setup_grub_migration.sh (v2)
#
# Only the parts that genuinely can't be a config file: package installs,
# grub-install, rebuilding initramfs/grub.cfg, enabling grub-btrfsd. The
# actual GRUB config (/etc/default/grub) and mkinitcpio preset are
# expected to already be in place via restore-system-config.sh.
#
# Run restore-system-config.sh BEFORE this script.

set -e

echo "=== [1/4] Installing GRUB ==="
sudo pacman -S --noconfirm --needed grub efibootmgr
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck

echo "=== [2/4] Rebuilding the initramfs ==="
sudo mkinitcpio -P

echo "=== [3/4] Generating grub.cfg ==="
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "=== [4/4] Installing grub-btrfs ==="
yay -S --noconfirm --needed grub-btrfs
sudo systemctl enable --now grub-btrfsd

echo ""
echo "============================================"
echo "Config applied. Manual verification is still required:"
echo "  1. sudo efibootmgr -v   # confirm GRUB is first in BootOrder"
echo "  2. sudo reboot"
echo "  3. If it fails, use your firmware's one-time boot key to fall"
echo "     back to the old bootloader entry — untouched."
echo "  4. Once booted: swapon --show / findmnt /"
echo "============================================"
