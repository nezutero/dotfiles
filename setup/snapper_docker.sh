#!/bin/bash
# setup_snapper_docker.sh (v2)
#
# Only the parts that genuinely can't be a config file: package installs,
# creating the .snapshots subvolume, isolating Docker's data. The actual
# snapper config (/etc/snapper/configs/root, /etc/conf.d/snapper) is
# expected to already be in place via restore-system-config.sh.
#
# Run restore-system-config.sh BEFORE this script.

set -e

echo "=== [1/3] Installing snapper + snap-pac ==="
sudo pacman -S --noconfirm --needed snapper snap-pac

echo "=== [2/3] Creating the .snapshots subvolume ==="
if ! sudo btrfs subvolume show /.snapshots &>/dev/null; then
    sudo btrfs subvolume create /.snapshots
    sudo chmod 750 /.snapshots
    echo "Created /.snapshots and fixed permissions."
else
    echo "/.snapshots already exists, skipping."
fi

sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer

echo "=== [3/3] Moving Docker's data onto its own subvolume ==="
if sudo btrfs subvolume show /var/lib/docker &>/dev/null; then
    echo "/var/lib/docker is already a subvolume, skipping."
else
    sudo systemctl stop docker.service docker.socket 2>/dev/null || true
    if [ -d /var/lib/docker ] && [ "$(ls -A /var/lib/docker 2>/dev/null)" ]; then
        sudo mv /var/lib/docker /var/lib/docker.old
        sudo btrfs subvolume create /var/lib/docker
        sudo rsync -aHAX /var/lib/docker.old/ /var/lib/docker/
        sudo rm -rf /var/lib/docker.old
    else
        sudo rm -rf /var/lib/docker 2>/dev/null || true
        sudo btrfs subvolume create /var/lib/docker
    fi
    echo "Docker data now lives on its own subvolume."
fi

echo ""
echo "Done. Verify with: sudo snapper -c root list"
