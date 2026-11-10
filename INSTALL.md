# Void Linux install: UEFI, fully encrypted (including /boot), GRUB, runit

The Void installer (`void-installer`) has no encryption option, so the encrypted
install is done by hand from the live ISO. It follows Void's own
full-disk-encryption guide, simplified (no LVM) and with variables instead of
hard-coded device names. Allow 20-30 minutes.

Use the **glibc** live image, not musl. Prebuilt binaries (Zen, Tor Browser,
nvim plugins, ...) assume glibc, which is also why the `nix-ld` block from your
NixOS config has no Void equivalent: you don't need one.

## How it works (read this once, it is the part worth learning)

| Partition | Size  | Contents |
|-----------|-------|----------|
| 1         | 512 MiB | EFI System Partition, **not encrypted**, mounted at `/boot/efi`. Only the GRUB program lives here. |
| 2         | rest  | **LUKS1** container. Inside: one ext4 filesystem holding `/`, `/boot`, `/home` and the swapfile. |

The boot chain:

1. The firmware loads GRUB from the ESP. This is the one unencrypted piece; the
   firmware can't read LUKS, so something has to be readable.
2. GRUB asks for your passphrase, unlocks the LUKS container itself, and reads
   the kernel and initramfs from the (now readable) encrypted `/boot`.
3. The kernel starts with the initramfs. The initramfs has to unlock the *same*
   container again, because GRUB's unlocked view is not handed over to Linux.
   To avoid typing the passphrase twice, a random **keyfile** is added as a
   second way to unlock the container and is copied into the initramfs. That's
   safe: the initramfs sits inside the encrypted `/boot`, so the keyfile is only
   readable after you've already typed the passphrase.
4. Linux mounts the root filesystem and boot continues normally.

Why LUKS1: GRUB can only unlock LUKS2 containers if they use the PBKDF2 key
derivation, not LUKS2's default Argon2. Void's guide picks LUKS1 to avoid the
problem. The cipher is the same AES-XTS either way; what differs is the key
derivation and header format. Because the passphrase is only checked by a
slow hash, a long passphrase matters more than usual.

What is still not covered: the ESP can be swapped by someone with physical
access (the "evil maid" case from earlier). Fixing that means Secure Boot with
your own keys, which is a separate project.

## Day to day: does it get in the way?

- After the passphrase at boot, you won't notice it. Disk speed on a modern CPU
  is barely affected.
- `xbps-install -Syu` works as usual. Kernel updates rebuild the initramfs and
  `grub.cfg` through Void's hooks, and dracut picks up the keyfile from the
  config below, so nothing extra to do.
- Debugging a broken system: boot the live ISO and run
  `cryptsetup open <partition> cryptroot`, `mount /dev/mapper/cryptroot /mnt`,
  `mount <esp> /mnt/boot/efi`, then `xchroot /mnt`. That's the whole recovery
  procedure, and it's the same steps as the install.
- Expect the GRUB unlock to take several seconds. That is normal (GRUB's key
  derivation is slow).

## 1. Live ISO: partition, encrypt, install

Get online first: Ethernet or USB tethering is easiest. For Wi-Fi, the
"Network" entry in `void-installer` can configure it (exit the installer
afterwards).

**GRUB reads your passphrase with a US (QWERTY) keymap**, regardless of your
keyboard. Switch the live ISO to the same layout *before* creating the
passphrase so that what you type now is what GRUB receives later:

```sh
loadkeys us        # type the passphrase by key position, as on a US keyboard
```

On an AZERTY keyboard, `a`/`q`, `z`/`w`, `m`, digits and punctuation move
around. A passphrase made of several random lowercase words with spaces is the
easiest to get right. If you ever do mistype it at the GRUB prompt, nothing is
lost: boot the live ISO and fix it.

**Check the device name with `lsblk` before running anything. This wipes it.**

```sh
# NVMe:  /dev/nvme0n1  with partitions p1, p2
# SATA:  /dev/sda      with partitions 1, 2
export DISK=/dev/nvme0n1
export ESP=${DISK}p1
export LUKS_PART=${DISK}p2

sfdisk "$DISK" <<'EOF'
label: gpt
size=512MiB, type=U
type=L
EOF

mkfs.vfat -F32 -n ESP "$ESP"

cryptsetup luksFormat --type luks1 "$LUKS_PART"     # type YES in capitals, then the passphrase twice
cryptsetup open "$LUKS_PART" cryptroot
mkfs.ext4 -L void /dev/mapper/cryptroot

mount /dev/mapper/cryptroot /mnt
mkdir -p /mnt/boot/efi
mount "$ESP" /mnt/boot/efi
```

Install the base system. `cryptsetup` is needed so the initramfs can unlock the
disk. Add `linux-firmware-amd` or `linux-firmware-intel` for your hardware
(`base-system` only brings the network firmware).

```sh
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt \
  base-system cryptsetup grub-x86_64-efi NetworkManager dbus sudo git neovim

xgenfstab /mnt > /mnt/etc/fstab     # writes UUID-based entries for what is mounted now
xchroot /mnt
```

## 2. Inside the chroot

`xchroot` starts a new shell, so define the device variables again (same values
as above):

```sh
export DISK=/dev/nvme0n1
export ESP=${DISK}p1
export LUKS_PART=${DISK}p2

chown root:root /
chmod 755 /
passwd root
echo myhostname > /etc/hostname                    # pick a hostname
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Locales (same ones as your NixOS config)
sed -i -E 's/^#(en_US\.UTF-8|en_GB\.UTF-8|fr_FR\.UTF-8) /\1 /' /etc/default/libc-locales
cat > /etc/locale.conf <<'EOF'
LANG=en_US.UTF-8
LC_TIME=en_GB.UTF-8
LC_ADDRESS=fr_FR.UTF-8
LC_IDENTIFICATION=fr_FR.UTF-8
LC_MEASUREMENT=fr_FR.UTF-8
LC_MONETARY=fr_FR.UTF-8
LC_NAME=fr_FR.UTF-8
LC_NUMERIC=fr_FR.UTF-8
LC_PAPER=fr_FR.UTF-8
LC_TELEPHONE=fr_FR.UTF-8
EOF
xbps-reconfigure -f glibc-locales

echo 'tmpfs  /tmp  tmpfs  defaults,nosuid,nodev  0 0' >> /etc/fstab
cat /etc/fstab        # should list / (ext4) and /boot/efi (vfat) by UUID
```

### Encryption setup

```sh
LUKS_UUID=$(blkid -s UUID -o value "$LUKS_PART")
echo "$LUKS_UUID"      # must be a real UUID, not empty

# 1. Let GRUB unlock the disk, and tell the initramfs which container to open
echo 'GRUB_ENABLE_CRYPTODISK=y' >> /etc/default/grub
sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\"|&rd.luks.uuid=$LUKS_UUID |" /etc/default/grub
grep -E 'CRYPTODISK|rd.luks' /etc/default/grub

# 2. Keyfile: a second way to unlock, so you only type the passphrase once
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey "$LUKS_PART" /boot/volume.key      # asks for your passphrase
chmod 000 /boot/volume.key
chmod go-rwx /boot                                       # the initramfs contains the key

# 3. Tell the initramfs about the container and the keyfile
echo "cryptroot  UUID=$LUKS_UUID  /boot/volume.key  luks" > /etc/crypttab
cat > /etc/dracut.conf.d/10-crypt.conf <<'EOF'
add_dracutmodules+=" crypt "
install_items+=" /boot/volume.key /etc/crypttab "
EOF

# 4. Install GRUB, then build initramfs + grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=void
xbps-reconfigure -fa
```

Sanity checks before rebooting (all three should print something):

```sh
ls /boot                                          # vmlinuz-*, initramfs-*.img
grep -c rd.luks.uuid /boot/grub/grub.cfg          # 1 or more
lsinitrd /boot/initramfs-*.img | grep -E 'volume.key|crypttab'
```

If the last one prints nothing, the keyfile isn't in the initramfs and you'd be
asked for the passphrase twice. Fix `/etc/dracut.conf.d/10-crypt.conf` and run
`xbps-reconfigure -f linux$(uname -r | cut -d. -f1-2)` (or just `xbps-reconfigure -fa`).

### User and first services

```sh
useradd -m -G wheel,audio,video -s /bin/bash nezutero
passwd nezutero
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# Just enough services to get online on first boot (init.sh enables the rest)
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/

exit
```

```sh
umount -R /mnt
cryptsetup close cryptroot
reboot
```

## 3. First boot

The firmware loads GRUB, GRUB shows an "Enter passphrase" prompt (plain text,
before any menu), then Linux boots straight to a login on tty1, with no second
prompt.

```sh
nmtui                                   # connect to Wi-Fi
git clone <your-dotfiles-url> ~/dotfiles
cd ~/dotfiles && ./init.sh
reboot
```

At the ly screen choose **Sway (D-Bus)**. The repo has to stay where it is:
the config files in `~/.config` are symlinks into it.

## Back up the LUKS header (do this once, right after first boot)

The header holds the encrypted master key. If it gets damaged, the data is
unrecoverable even with the right passphrase. Save a copy somewhere that is
**not** this disk (a USB stick, your password store's backup):

```sh
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 --header-backup-file luks-header.img
```

Treat that file as sensitive: anyone with it and the old passphrase can unlock the
disk, so it is only safe to store where the passphrase isn't.

## Swap

Not part of the install. `init.sh` sets up zram swap (zstd, 50% of RAM, priority
100) through the `zramen` runit service, plus a 17 GiB swapfile at priority 10
as fallback. Both are mounted after boot, and the swapfile sits inside the
encrypted root, so swapped-out memory is encrypted too. Check with
`cat /proc/swaps`.

## Optional: SSD TRIM through LUKS

Off by default. Enabling it means adding `rd.luks.allow-discards` next to
`rd.luks.uuid=...` in `/etc/default/grub` (then `xbps-reconfigure -fa`) and
running `fstrim -av` now and then. The cost: someone with the disk can see which
blocks are unused.
