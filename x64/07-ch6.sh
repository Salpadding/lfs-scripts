#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"
source "lfs_env.sh"
check_lfs

source "${cur}/install_helpers.sh"

install_m4() {
    reinstall m4
    push_into m4

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install
    popd
}


install_ncurses() {
    reinstall ncurses
    push_into ncurses
    {
        sed -i s/mawk// configure
        mkdir build
        pushd build
        {
            ../configure
            make -C include
            make -C progs tic
            popd
        }

        ./configure --prefix=/usr                \
                --host=$LFS_TGT              \
                --build=$(./config.guess)    \
                --mandir=/usr/share/man      \
                --with-manpage-format=normal \
                --with-shared                \
                --without-normal             \
                --with-cxx-shared            \
                --without-debug              \
                --without-ada                \
                --disable-stripping          \
                --enable-widec

        safe_make 
        make DESTDIR="${LFS}" TIC_PATH=$(pwd)/build/progs/tic install
        ln -sv libncursesw.so "${LFS}/usr/lib/libncurses.so"
        sed -e 's/^#if.*XOPEN.*$/#if 1/' \
            -i $LFS/usr/include/curses.h
        popd
    }
}


install_bash() {
    reinstall bash
    push_into bash

    ./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

    safe_make
    make DESTDIR=$LFS install

    ln -sv bash $LFS/bin/sh

    popd
}

install_coreutils() {
    reinstall coreutils
    push_into coreutils
./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

    safe_make
    make DESTDIR=$LFS install


    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

    popd
}

install_diff() {
    reinstall diffutils
    push_into diffutils

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install

    popd
}

install_file() {
    reinstall file
    push_into file

    mkdir build
    pushd build

    {
        ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
        safe_make

        popd
    }

    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
    make DESTDIR=$LFS install
    make FILE_COMPILE=$(pwd)/build/src/file
    rm -v $LFS/usr/lib/libmagic.la


    popd
}

install_find() {
    reinstall findutils
    push_into findutils

./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install

    popd
}

install_awk() {
    reinstall gawk
    push_into gawk


    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install

    popd
}

install_grep() {
    reinstall grep
    push_into grep

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install

    popd
}

install_gzip() {
    reinstall gzip
    push_into gzip

    ./configure --prefix=/usr --host=$LFS_TGT
    safe_make
    make DESTDIR=$LFS install

    popd
}

install_make() {
    reinstall make
    push_into make

    ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install


    popd
}

install_patch() {
    reinstall patch
    push_into patch

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install


    popd
}

install_sed() {
    reinstall sed
    push_into sed

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install


    popd
}

install_tar() {
    reinstall tar
    push_into tar

    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

    safe_make
    make DESTDIR=$LFS install


    popd
}


install_xz() {
    reinstall xz
    push_into xz

    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.4.6

    safe_make
    make DESTDIR=$LFS install

    rm -v $LFS/usr/lib/liblzma.la


    popd
}

install_binutils_p2() {
    reinstall binutils
    push_into binutils

    sed '6009s/$add_dir//' -i ltmain.sh
    mkdir -v build
    pushd build

    {
        ../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$LFS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --enable-default-hash-style=gnu

        safe_make
        make DESTDIR=$LFS install
        rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}


        popd 
    }


    popd
}

install_gcc_p2() {
    reinstall gcc mpfr gmp mpc
    move_into gcc mpfr gmp mpc

    push_into gcc

    case $(uname -m) in
    x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
    ;;
    esac
    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

    mkdir -v build
    pushd    build 
    {
    ../configure                                       \
    --build=$(../config.guess)                     \
    --host=$LFS_TGT                                \
    --target=$LFS_TGT                              \
    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
    --prefix=/usr                                  \
    --with-build-sysroot=$LFS                      \
    --enable-default-pie                           \
    --enable-default-ssp                           \
    --disable-nls                                  \
    --disable-multilib                             \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libsanitizer                         \
    --disable-libssp                               \
    --disable-libvtv                               \
    --enable-languages=c,c++

        safe_make
        make DESTDIR=$LFS install

        ln -sv gcc $LFS/usr/bin/cc
        popd
    }


    popd
}

all() {
install_m4
install_ncurses
install_bash
install_coreutils
install_diff
install_file
install_find
install_awk
install_grep
install_gzip
install_make
install_patch
install_sed
install_tar
install_xz
install_binutils_p2
install_gcc_p2
}

[[ -n "${*}" ]] && "${@}"

popd
