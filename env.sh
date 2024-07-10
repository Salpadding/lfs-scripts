#!/bin/bash

# 关闭 hash 每次都重新查找可执行文件位置
set -h
export LFS=/mnt/lfs
export LFS_TGT=aarch64-lfs-linux-gnu
export PATH=/usr/bin
export PATH="${LFS}/tools/bin:${PATH}"
export CONFIG_SITE="${LFS}/usr/share/config.site"

# $1: url $2: directory name
keep_install() {
    local url="${1}"
    local dir="${2}"
    [[ -f `basename ${url}` ]] || wget "${url}"
    [[ -z "${dir}" ]] && return
    [[ -d "${dir}" ]] || tar -xf `basename ${url}` -C .
}
