#!/bin/bash

LFS=/mnt/lfs

! [[ -d `pwd`/x64 ]] && echo invalid lfs project root && exit 1

losetup -P /dev/loop0 /var/lib/lfs/lfs.img
mount /dev/loop0p2 "${LFS}"
mkdir -p "${LFS}/lfs"
mount --bind `pwd` "${LFS}/lfs"
mount --bind `pwd`/sources "${LFS}/sources"


mount -v --bind /dev $LFS/dev
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run


if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
