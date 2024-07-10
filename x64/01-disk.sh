#!/usr/bin/env bash
# create loop disk
#
sudo mkdir -p /var/lib/lfs
me=`whoami`

sudo chown ${me} /var/lib/lfs

# create two partition
if ! [[ -f /var/lib/lfs/lfs.img ]]; then
    qemu-img create -f raw /var/lib/lfs/lfs.img 64G

    echo -en 'g\nn\n\n\n+256M\nn\n\n\n\n\np\nw\n' | sudo fdisk /var/lib/lfs/lfs.img
fi

# mount it
lfs_loop=`losetup -f`
sudo losetup -P "${lfs_loop}" /var/lib/lfs/lfs.img

sudo mkfs.ext4 "${lfs_loop}p2"
sudo mkdir -p /mnt/lfs
sudo chown "${me}" /mnt/lfs
sudo mount "${lfs_loop}p2" /mnt/lfs
