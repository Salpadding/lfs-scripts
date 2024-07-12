#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"
source "lfs_env.sh"
check_lfs

chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
 x86_64)  chown -R root:root $LFS/lib64 ;;
esac

mkdir -pv $LFS/{dev,proc,sys,run}
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

mkdir -p /mnt/lfs/lfs
mount --bind `${cur}/..` /mnt/lfs/lfs
mount --bind `${cur}/../sources` /mnt/lfs/sources

