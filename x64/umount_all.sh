#!/bin/bash

LFS=/mnt/lfs

safe_umount() {
mountpoint -q "${1}" && umount "${1}" || return 0
}

safe_umount "${LFS}/dev/shm"
safe_umount "${LFS}/run"
safe_umount "${LFS}/sys"
safe_umount "${LFS}/proc"
safe_umount "${LFS}/dev/pts"
safe_umount "${LFS}/dev"
safe_umount "${LFS}/sources"
safe_umount "${LFS}/lfs"
safe_umount "${LFS}"

losetup -d /dev/loop0



