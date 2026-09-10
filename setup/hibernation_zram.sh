#!/bin/bash
#
# Configures zram (fast, everyday swap) + a Btrfs swapfile (used only for
# hibernation) on a system with:
#   - Btrfs root, subvol=@
#   - LUKS root unlocked to /dev/mapper/root
#   - mkinitcpio with the (busybox) "encrypt" hook
#   - systemd-boot with a UKI (kernel cmdline lives in /etc/kernel/cmdline)
#
# Safe to re-run: every step checks whether it's already done before acting.
# Run this AFTER the base system + bootloader are already working, and
# BEFORE you expect hibernation to work (a reboot is required at the end).

set -e

echo "=== [1/5] Configuring zram ==="

ZRAM_CONF=/etc/systemd/zram-generator.conf
if [ ! -f "$ZRAM_CONF" ]; then
    sudo pacman -S --noconfirm --needed zram-generator
    sudo tee "$ZRAM_CONF" > /dev/null <<EOF
[zram0]
zram-size = 4096
compression-algorithm = zstd
swap-priority = 100
EOF
    sudo systemctl daemon-reload
    sudo systemctl start systemd-zram-setup@zram0.service
    echo "zram-generator installed and configured (4G, zstd, priority 100)."
else
    echo "zram-generator.conf already present, leaving it alone."
fi

echo "=== [2/5] Creating Btrfs swap file for hibernation ==="

# Size = total RAM (rounded up to whole GB) + 1G headroom
RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM_GB=$(( (RAM_KB + 1048575) / 1048576 ))
SWAP_GB=$(( RAM_GB + 1 ))

if [ ! -d /swap ]; then
    sudo btrfs subvolume create /swap
    echo "Created /swap subvolume."
fi

if [ ! -f /swap/swapfile ]; then
    echo "Creating ${SWAP_GB}G swapfile (detected ${RAM_GB}G RAM)..."
    sudo btrfs filesystem mkswapfile --size "${SWAP_GB}g" --uuid clear /swap/swapfile
else
    echo "/swap/swapfile already exists, leaving it alone."
    echo "(Delete it manually first if you need to resize it.)"
fi

if ! grep -q '/swap/swapfile' /etc/fstab; then
    {
        echo ""
        echo "# /swap/swapfile"
        printf '/swap/swapfile\tnone\tswap\tdefaults,pri=-2\t0 0\n'
    } | sudo tee -a /etc/fstab > /dev/null
    echo "Added swapfile entry to /etc/fstab."
fi

sudo swapon -a

echo "=== [3/5] Adding resume hook to mkinitcpio ==="

if grep -qE '^HOOKS=.*\bresume\b' /etc/mkinitcpio.conf; then
    echo "resume hook already present, skipping."
else
    sudo sed -i '/^HOOKS=/ s/\bencrypt\b/encrypt resume/' /etc/mkinitcpio.conf
    echo "Inserted resume hook after encrypt."
fi

echo "=== [4/5] Wiring resume= into the kernel cmdline ==="

CMDLINE_FILE=/etc/kernel/cmdline
ROOT_UUID=$(findmnt -no UUID -T /)
OFFSET=$(sudo btrfs inspect-internal map-swapfile -r /swap/swapfile)

if grep -q 'resume=' "$CMDLINE_FILE"; then
    echo "resume= already present in $CMDLINE_FILE, skipping."
    echo "(If you recreated the swapfile, delete the old resume=/resume_offset= manually and re-run.)"
else
    sudo sed -i "s|\$| resume=UUID=${ROOT_UUID} resume_offset=${OFFSET}|" "$CMDLINE_FILE"
    echo "Added resume=UUID=${ROOT_UUID} resume_offset=${OFFSET}"
fi

echo "=== [5/5] Rebuilding the UKI ==="
sudo mkinitcpio -P

echo ""
echo "============================================"
echo "Hibernation + zram setup complete."
echo "Reboot once, then test with: systemctl hibernate"
echo "============================================"
