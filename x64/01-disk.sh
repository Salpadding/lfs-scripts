#!/usr/bin/env bash
# create loop disk
#
[[ "$(id -u)" -ne 0 ]] && use root please && exit 1

mkdir -p /var/lib/lfs

# create two partition
if ! [[ -f /var/lib/lfs/lfs.img ]]; then
    qemu-img create -f raw /var/lib/lfs/lfs.img 64G

    echo -en 'g\nn\n\n\n+256M\nn\n\n\n\n\np\nw\n' | sudo fdisk /var/lib/lfs/lfs.img
fi

# mount it
lfs_loop=`losetup -f`
losetup -P "${lfs_loop}" /var/lib/lfs/lfs.img

mkfs.ext4 "${lfs_loop}p2"
mkdir -p /mnt/lfs
chown "${me}" /mnt/lfs
mount "${lfs_loop}p2" /mnt/lfs
