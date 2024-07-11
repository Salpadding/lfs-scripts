#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"
source "lfs_env.sh"
check_lfs

source "${cur}/install_helpers.sh"

install_binutils() {
    reinstall binutils
    push_into binutils

    mkdir -p build
    pushd build
    ../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu
    safe_make
    make install
    popd
    popd
}

install_gcc() {
    reinstall gcc mpfr gmp mpc
    move_into gcc mpfr gmp mpc

    push_into gcc

    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
     ;;
    esac

    mkdir -v build
    pushd       build

    ../configure                  \
    --target=$LFS_TGT         \
    --prefix=$LFS/tools       \
    --with-glibc-version=2.39 \
    --with-sysroot=$LFS       \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
    --enable-languages=c,c++

    safe_make
    make install

    # pop build
    popd

    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h

    # pop gcc
    popd
}


install_linux_header() {
    reinstall linux
    push_into linux

    make mrproper
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr

    popd
}



install_glibc() {
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac


    reinstall glibc
    push_into glibc


    mkdir build
    pushd build

    echo "rootsbindir=/usr/sbin" > configparms
    ../configure                             \
      --prefix=/usr                      \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=4.19               \
      --with-headers=$LFS/usr/include    \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib

    safe_make
    make DESTDIR=$LFS install
    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd


    popd
    popd
}


install_libstdcpp() {
    push_into gcc

    rm -rf build
    mkdir build
    pushd build

    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --build=$(../config.guess)      \
        --prefix=/usr                   \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/13.2.0

    safe_make
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

    popd
    popd
}

all() {
install_binutils
install_gcc
install_linux_header
install_glibc
install_libstdcpp
}


[[ -n "${*}" ]] && "${@}"



popd

