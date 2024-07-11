#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
pushd "${cur}"

export LFS=/

source "install_helpers.sh"

install_gettext() {
    reinstall gettext
    push_into gettext

    ./configure --disable-shared

    safe_make

    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin


    popd
}

install_bison() {
    reinstall bison
    push_into bison

./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

    safe_make
    make install
    popd
}

install_perl() {
    reinstall perl
    push_into perl

sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Duseshrplib                                \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl     \
             -Darchlib=/usr/lib/perl5/5.38/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl

    safe_make
    make install

    popd
}

install_py() {
   reinstall Python
   push_into Python

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

    safe_make
    make install

    popd 
}

install_texinfo() {
    reinstall texinfo 
    push_into texinfo

    ./configure --prefix=/usr

    safe_make
    make install

    popd
}

install_util_linux() {
    reinstall util-linux
    push_into util-linux

    mkdir -pv /var/lib/hwclock
./configure --libdir=/usr/lib    \
            --runstatedir=/run   \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.39.3


    safe_make
    make install

    popd
}

install_clean() {
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
}


all() {
install_gettext
install_bison
install_perl
install_py
install_texinfo
install_util_linux
install_clean
}

[[ -n "${*}" ]] && "${@}"

popd
