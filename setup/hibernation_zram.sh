#!/bin/bash
# setup_hibernation_zram.sh (v2)
#
# Only the parts that genuinely can't be a config file: package installs,
# subvolume/swapfile creation, activating swap. Everything else (fstab's
# swap line, zram-generator.conf, the resume hook in mkinitcpio.conf) is
# expected to already be in place via restore-system-config.sh.
#
# Run restore-system-config.sh BEFORE this script.

set -e

echo "=== [1/2] Installing and starting zram-generator ==="
sudo pacman -S --noconfirm --needed zram-generator
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true

echo "=== [2/2] Creating the Btrfs swap file for hibernation ==="
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$(( (RAM_KB + 1048575) / 1048576 ))
SWAP_GB=$(( RAM_GB + 1 ))

if [ ! -d /swap ]; then
    sudo btrfs subvolume create /swap
fi

if [ ! -f /swap/swapfile ]; then
    echo "Creating ${SWAP_GB}G swapfile (detected ${RAM_GB}G RAM)..."
    sudo btrfs filesystem mkswapfile --size "${SWAP_GB}g" --uuid clear /swap/swapfile
else
    echo "/swap/swapfile already exists, leaving it alone."
fi

sudo swapon -a

echo ""
echo "Done. If this is a fresh swapfile (not restored from a previous"
echo "capture), recompute the resume offset and update /etc/default/grub's"
echo "GRUB_CMDLINE_LINUX before running setup_grub_migration.sh:"
echo "  sudo btrfs inspect-internal map-swapfile -r /swap/swapfile"
