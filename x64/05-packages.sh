#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"
source "lfs_env.sh"


packages=(
    https://sourceware.org/pub/binutils/releases/binutils-2.42.tar.xz

    # gcc
    https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
    https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz
    https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
    https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz

    # linux header
    https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.7.4.tar.gz

    # glibc
    https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz

    # m4
    https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz

    # ncurses
    https://anduin.linuxfromscratch.org/LFS/ncurses-6.4-20230520.tar.xz

    # bash
    https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz

    # coreutils
    https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz

    # diffutils
    https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz

    # file
    https://astron.com/pub/file/file-5.45.tar.gz

    # findutils
    https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz
    
    # gawk
    https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz

    # grep
    https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz

    # gzip
    https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz

    # make
    https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz

    # patch
    https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz

    # sed
    https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz

    # tar
    https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz

    # xz
    https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.xz

    https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz
    https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz
    https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz
    https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz
    https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz
    https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.3.tar.xz
)


install_all() {
pushd "${LFS}/sources"
for p in "${packages[@]}"; do
    [[ -f `basename ${p}` ]] || wget "${p}"
done
popd
}

# 以 包名 版本号 格式输出
dump_all() {
rm packages.csv
for p in "${packages[@]}"; do
    local base=`basename "${p}"`
    # remove extensions
    local stripped=`echo "${base}" | sed -e 's/.tar.xz$//' -e 's/.tar.gz$//'`
    local awk_expr='{print $1}'
    local name=`echo "${stripped}" | sed -E 's/-[0-9.]+(-[0-9]+)?$//'`
    local version=`echo "${stripped}" | sed "s/^${name}-//"`
    echo "${name} ${version} ${p}" >> packages.csv
done
}

[[ -n "${*}" ]] && "${@}"

popd
