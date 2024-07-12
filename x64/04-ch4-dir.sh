#!/bin/bash

[[ "$(id -u)" -ne 0 ]] && use root please && exit 1

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"
source "env.sh"

check_lfs

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
  ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools


popd
