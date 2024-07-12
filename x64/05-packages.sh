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

    https://www.kernel.org/pub/linux/docs/man-pages/man-pages-6.06.tar.xz
    https://github.com/Mic92/iana-etc/releases/download/20240125/iana-etc-20240125.tar.gz
    https://zlib.net/fossils/zlib-1.3.1.tar.gz    
    https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz
    https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz
    https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz
    https://github.com/gavinhoward/bc/releases/download/6.7.5/bc-6.7.5.tar.xz
    https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
    https://downloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz
    https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz
    https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz
    https://distfiles.ariadne.space/pkgconf/pkgconf-2.1.1.tar.xz
    https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz
    https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz
    https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.69.tar.xz
    https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz
    https://github.com/shadow-maint/shadow/releases/download/4.14.5/shadow-4.14.5.tar.xz
    https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.6.tar.xz
    https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz
    https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz
    https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz
    http://sources.buildroot.net/expat/expat-2.6.0.tar.xz
    https://ftp.gnu.org/gnu/inetutils/inetutils-2.5.tar.xz
    https://www.greenwoodsoftware.com/less/less-643.tar.gz
    https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz
    https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz
    https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz
    https://www.openssl.org/source/openssl-3.2.1.tar.gz
    https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-31.tar.xz
    https://sourceware.org/ftp/elfutils/0.190/elfutils-0.190.tar.bz2
    https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz
    https://pypi.org/packages/source/f/flit-core/flit_core-3.9.0.tar.gz
    https://pypi.org/packages/source/w/wheel/wheel-0.42.0.tar.gz
    https://pypi.org/packages/source/s/setuptools/setuptools-69.1.0.tar.gz
    https://github.com/ninja-build/ninja/archive/v1.11.1/ninja-1.11.1.tar.gz
    https://github.com/mesonbuild/meson/releases/download/1.3.2/meson-1.3.2.tar.gz
    https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz
    https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz
    https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.7.0.tar.xz
    https://www.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz
    https://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.7.tar.gz
    https://github.com/vim/vim/archive/v9.1.0041/vim-9.1.0041.tar.gz
    https://pypi.org/packages/source/M/MarkupSafe/MarkupSafe-2.1.5.tar.gz
    https://pypi.org/packages/source/J/Jinja2/Jinja2-3.1.3.tar.gz
    https://anduin.linuxfromscratch.org/LFS/udev-lfs-20230818.tar.xz
    https://download.savannah.gnu.org/releases/man-db/man-db-2.12.0.tar.xz
    https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-4.0.4.tar.xz
    https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.0/e2fsprogs-1.47.0.tar.gz
    https://www.infodrom.org/projects/sysklogd/download/sysklogd-1.5.1.tar.gz
    https://github.com/slicer69/sysvinit/releases/download/3.08/sysvinit-3.08.tar.xz
    https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz
    https://github.com/systemd/systemd/archive/v255/systemd-255.tar.gz
)


install_all() {
pushd "${LFS}/sources"

local extras=(
https://downloads.sourceforge.net/tcl/tcl8.6.13-html.tar.gz
)

for p in "${packages[@]}"; do
    [[ -f `basename ${p}` ]] || wget "${p}"
done

for p in "${extras[@]}"; do
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
    local stripped=`echo "${base}" | sed -e 's/.tar.xz$//' -e 's/.tar.gz$//' -e 's/.tar.bz2$//'`
    local awk_expr='{print $1}'
    local name=`echo "${stripped}" | sed -E 's/-[0-9.]+(-[0-9]+)?$//'`
    local version=`echo "${stripped}" | sed "s/^${name}-//"`
    echo "${name} ${version} ${p}" >> packages.csv
done
}

install_patch() {
    pushd "${LFS}/sources"
    cat "${cur}/patch.csv" | while read line; do 
        local url=$(echo "${line}" | awk '{print $2}')
        local base=$(basename ${url})
        
        [[ -f "${base}" ]] || wget "${url}"
    done

    popd
}

[[ -n "${*}" ]] && "${@}" || dump_all

popd
