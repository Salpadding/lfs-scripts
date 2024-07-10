#!/bin/bash

source "env.sh"

# 安装 binutils
install_binutils() {
    local ver=2.42
    local url="https://sourceware.org/pub/binutils/releases/binutils-${ver}.tar.xz"
    pushd "${LFS}/sources"
    
    [[ -f `basename ${url}` ]] || wget -O "binutils-${ver}.tar.xz" "${url}"

    tar -xf "binutils-${ver}.tar.xz" -C .
    pushd  "binutils-${ver}"
    mkdir -p build
    pushd build
    ../configure --prefix=$LFS/tools \
             --with-sysroot=$LFS \
             --target=$LFS_TGT   \
             --disable-nls       \
             --enable-gprofng=no \
             --disable-werror    \
             --enable-default-hash-style=gnu
    make "-j$(nproc)"
    make install
    popd
    popd
    popd
}


# 安装 gcc
install_gcc() {
    pushd "${LFS}/sources"

    local cc_url="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
    local mpfr_url="https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
    local gmp_url="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
    local mpc_url="https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"

    for src in "${cc_url}" "${mpfr_url}" "${gmp_url}" "${mpc_url}"; do
        local b=`basename ${src}`
        [[ -f "${b}" ]] || wget "${src}"
    done

    tar -xf gcc-13.2.0.tar.xz
    tar -xf mpfr-4.2.1.tar.xz -C gcc-13.2.0
    tar -xf gmp-6.3.0.tar.xz -C gcc-13.2.0
    tar -xf mpc-1.3.1.tar.gz -C gcc-13.2.0

    mv gcc-13.2.0/mpfr-* gcc-13.2.0/mpfr
    mv gcc-13.2.0/gmp-* gcc-13.2.0/gmp
    mv gcc-13.2.0/mpc-* gcc-13.2.0/mpc

    pushd gcc-13.2.0
    mkdir build
    pushd build

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

    make "-j$(nproc)"
    make install
    pushd ..

    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h
    popd

    popd
    popd
    popd
}

install_linux_header() {
    pushd "${LFS}/sources"
    local url='https://mirrors.tuna.tsinghua.edu.cn/kernel/v6.x/linux-6.7.4.tar.gz'

    [[ -f `basename ${url}` ]] || wget "${url}"
    [[ -d linux-6.7.4 ]] || tar -xf `basename ${url}`
    pushd linux-6.7.4
    make mrproper
    make -j4 headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr
    popd
    popd
}

install_glibc() {
    pushd "${LFS}/sources"
    local glibc_url=https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz
    local patch_url=https://www.linuxfromscratch.org/patches/lfs/12.1/glibc-2.39-fhs-1.patch

    [[ -f `basename ${glibc_url}` ]] || wget "${glibc_url}"
    [[ -f `basename ${patch_url}` ]] || wget "${patch_url}"

    
    [[ -d 'glibc-2.39' ]] || tar -xf glibc-2.39.tar.xz -C .
    pushd glibc-2.39
    patch -Np1 -i ../glibc-2.39-fhs-1.patch

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

    make -j4
    make DESTDIR=$LFS install
    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

    popd

    popd
    popd
}

install_libstdcpp() {
    pushd "${LFS}"
    [[ -d sources/gcc-13.2.0 ]] || return 1
    pushd sources/gcc-13.2.0 
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

    make -j4
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

    popd
    popd
}

install_m4() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz'
    keep_install "${url}" m4-1.4.19

    pushd m4-1.4.19

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
    
    make -j4
    make DESTDIR=$LFS install


    popd
    popd
}

install_ncurses() {
    pushd "${LFS}/sources"
    keep_install 'https://anduin.linuxfromscratch.org/LFS/ncurses-6.4-20230520.tar.xz' \
            'ncurses-6.4-20230520'

    pushd 'ncurses-6.4-20230520'
    pushd ncurses-6.4-20230520

    sed -i s/mawk// configure
    mkdir build
    pushd build
    ../configure
    make -C include -j4
    make -C progs tic -j4
    popd

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
    make -j4
    make DESTDIR="${LFS}" TIC_PATH=$(pwd)/build/progs/tic install
    ln -sv libncursesw.so "${LFS}/usr/lib/libncurses.so"
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i $LFS/usr/include/curses.h

    popd
    popd
}

install_bash() {
    pushd "${LFS}/sources"

    keep_install 'https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz' \
        'bash-5.2.21'

    keep_install 'https://www.linuxfromscratch.org/patches/lfs/12.1/bash-5.2.21-upstream_fixes-1.patch'

    pushd bash-5.2.21

    patch -Np1 -i ../bash-5.2.21-upstream_fixes-1.patch

    ./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

    make -j4
    make DESTDIR=$LFS install

    ln -sv bash $LFS/bin/sh
    
    popd
    popd
}

install_coreutils() {
    pushd "${LFS}/sources"

    keep_install 'https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz' coreutils-9.4
    keep_install 'https://www.linuxfromscratch.org/patches/lfs/12.1/coreutils-9.4-i18n-1.patch'

    pushd coreutils-9.4
    patch -Np1 -i ../coreutils-9.4-i18n-1.patch

    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

    make -j4
    make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8

    popd
    popd
}

install_diffutils() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz'
    keep_install "${url}" diffutils-3.10

    pushd diffutils-3.10
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}

install_file() {
    pushd "${LFS}/sources"
    local url='https://astron.com/pub/file/file-5.45.tar.gz'
    keep_install "${url}" file-5.45
    pushd file-5.45

    mkdir build
    {
        pushd build
        ../configure --disable-bzlib      \
            --disable-libseccomp \
            --disable-xzlib      \
            --disable-zlib
        make -j4
        popd
    }

    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
    make -j4 FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/libmagic.la


    popd
    popd
}

install_findutils() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz'
    keep_install  "${url}" findutils-4.9.0
    pushd findutils-4.9.0

    ./configure --prefix=/usr                   \
            --localstatedir=/var/lib/locate \
            --host=$LFS_TGT                 \
            --build=$(build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}

install_gawk() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz'
    keep_install  "${url}" gawk-5.3.0
    pushd gawk-5.3.0

    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}

install_grep() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz'
    keep_install  "${url}" grep-3.11
    pushd grep-3.11


    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}

install_gzip() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz'
    keep_install  "${url}" gzip-1.13
    pushd gzip-1.13

    ./configure --prefix=/usr --host=$LFS_TGT
    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}


install_make() {
    pushd "${LFS}/sources"
    local url='https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz'
    keep_install  "${url}" make-4.4.1
    pushd make-4.4.1

    ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}

install_patch() {
    local url='https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz'


    pushd "${LFS}/sources"
    keep_install  "${url}" patch-2.7.6
    pushd patch-2.7.6

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install


    popd
    popd
}


install_sed() {
    local url='https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz'

    pushd "${LFS}/sources"
    keep_install  "${url}" sed-4.9
    pushd sed-4.9

    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}


install_tar() {
    local url='https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz'

    pushd "${LFS}/sources"
    keep_install  "${url}" tar-1.35
    pushd tar-1.35

    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess)

    make -j4
    make DESTDIR=$LFS install

    popd
    popd
}


install_xz() {
    local url='https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.xz'

    pushd "${LFS}/sources"
    keep_install  "${url}" xz-5.4.6
    pushd xz-5.4.6

    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.4.6

    make -j4
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/liblzma.la


    popd
    popd
}


install_binutils_p2() {
    local ver=2.42
    pushd "${LFS}/sources"
    rm -rf "binutils-${ver}"
    tar -xf "binutils-${ver}.tar.xz" -C .
    pushd  "binutils-${ver}"

    
    sed '6009s/$add_dir//' -i ltmain.sh

    mkdir build
    pushd build

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

    make -j4
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

    popd
    popd
    popd
}

install_gcc_p2() {
    pushd "${LFS}/sources"
    rm -rf gcc-13.2.0

    tar -xf gcc-13.2.0.tar.xz
    tar -xf mpfr-4.2.1.tar.xz -C gcc-13.2.0
    tar -xf gmp-6.3.0.tar.xz -C gcc-13.2.0
    tar -xf mpc-1.3.1.tar.gz -C gcc-13.2.0

    mv gcc-13.2.0/mpfr-* gcc-13.2.0/mpfr
    mv gcc-13.2.0/gmp-* gcc-13.2.0/gmp
    mv gcc-13.2.0/mpc-* gcc-13.2.0/mpc

    pushd gcc-13.2.0

    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in


    mkdir build
    pushd build

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

    make -j4
    make DESTDIR=$LFS install
    ln -sv gcc $LFS/usr/bin/cc

    popd
    popd
    popd
}


[[ -n "${*}" ]] && "${@}"
