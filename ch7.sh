install_all() {
    local packages=(
'https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz'
'https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz'
'https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz'
'https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz'
'https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz'
'https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.3.tar.xz'
)

    pushd /mnt/lfs/sources

    for p in "${packages[@]}"; do
        [[ -f `basename ${p}` ]] || wget "${p}"
    done

    popd
}

extract_pushd() {
    local dir="${1}"
    local ext="${2}"

    [[ -d "${dir}" ]] && rm -rf "${dir}"
    tar -xf "${dir}${ext}" -C .

    pushd "${dir}"
}

install_gettext() {
    pushd "/sources"

    extract_pushd gettext-0.22.4 .tar.xz

    ./configure --disable-shared
    make -j4
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin


    popd
    popd
}

install_bison() {
    pushd "/sources"

    extract_pushd bison-3.8.2 .tar.xz 

    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2

    make -j4
    make install

    popd
    popd
}

install_perl() {
    pushd "/sources"

    extract_pushd perl-5.38.2 .tar.xz

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

    make -j4
    make install

    popd
    popd
}


install_py() {
    pushd "/sources"

    extract_pushd "Python-3.12.2" ".tar.xz"

./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip

    make -j4
    make install

    popd
    popd
}

install_texinfo() {
    pushd "/sources"
    extract_pushd "texinfo-7.1" ".tar.xz"

    ./configure --prefix=/usr
    make -j4
    make install

    popd
    popd
}

install_util_linux() {
    pushd "/sources"
    extract_pushd util-linux-2.39.3 .tar.xz

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

    make -j4
    make install

    popd
    popd
}


[[ -n "${*}" ]] && "${@}"
