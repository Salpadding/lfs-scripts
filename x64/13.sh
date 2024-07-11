#!/bin/bash

if [[ -z "${cur}" ]]; then
cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`
fi

pushd "${cur}"
source "install_helpers.sh"
popd

export LFS=/


install_package() {
case "${1}" in
man-pages)
    reinstall "${1}"
    push_into "${1}"

    rm -v man3/crypt*
    make prefix=/usr install

    popd
;;

iana-etc)
    reinstall "${1}"
    push_into "${1}"
    cp services protocols /etc

    popd
;;

glibc)
    reinstall "${1}"
    push_into "${1}"

    mkdir -v build
    pushd       build 
    
    echo "rootsbindir=/usr/sbin" > configparms

    ../configure --prefix=/usr                            \
                 --disable-werror                         \
                 --enable-kernel=4.19                     \
                 --enable-stack-protector=strong          \
                 --disable-nscd                           \
                 libc_cv_slibdir=/usr/lib

    safe_make
    make check
    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    make install
    sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd


    popd
    popd
;;

zlib)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr
    safe_make
    make check

    make install
    rm -fv /usr/lib/libz.a

    popd
;;

bzip2)
    reinstall "${1}"
    push_into "${1}"

    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    safe_make -f Makefile-libbz2_so
    make clean
    safe_make
    
    make PREFIX=/usr install
    cp -av libbz2.so.* /usr/lib
    ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

    cp -v bzip2-shared /usr/bin/bzip2
    for i in /usr/bin/{bzcat,bunzip2}; do
      ln -sfv bzip2 $i
    done

    rm -fv /usr/lib/libbz2.a

    popd
;;

xz)
    reinstall "${1}"
    push_into "${1}"

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.4.6

    safe_make
    make check
    make install
    

    popd
;;

zstd)
    reinstall "${1}"
    push_into "${1}"

    safe_make prefix=/usr
    make check

    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
 
    popd
;;

file)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr
    safe_make

    make check
    make install

    popd
;;

readline)
    reinstall "${1}"
    push_into "${1}"

    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2

    safe_make SHLIB_LIBS="-lncursesw"
    make SHLIB_LIBS="-lncursesw" install
    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2
;;
m4)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr
    safe_make
    make check
    make install
    popd
;;

bc)
    reinstall "${1}"
    push_into "${1}"

    CC=gcc ./configure --prefix=/usr -G -O3 -r
    safe_make
    make test
    make install

    popd
;;
flex)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static 

    safe_make
    make check
    make install
    
    ln -sv flex   /usr/bin/lex
    ln -sv flex.1 /usr/share/man/man1/lex.1

    popd
;;

tcl)
    reinstall "${1}"
    push_into "${1}"

    SRCDIR=$(pwd)
    pushd unix
    ./configure --prefix=/usr           \
            --mandir=/usr/share/man

    safe_make
    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|"            \
        -i pkgs/tdbc1.1.5/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
        -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|"            \
        -i pkgs/itcl4.2.3/itclConfig.sh

    unset SRCDIR    
    make test
    make install
    chmod -v u+w /usr/lib/libtcl8.6.so
    make install-private-headers

    ln -sfv tclsh8.6 /usr/bin/tclsh
    mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
    popd

    tar -xf ../tcl8.6.13-html.tar.gz --strip-components=1
    mkdir -v -p /usr/share/doc/tcl-8.6.13
    cp -v -r  ./html/* /usr/share/doc/tcl-8.6.13 

    popd
;;

expect)
    reinstall "${1}"
    push_into "${1}"


    ./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
    
    safe_make
    make test
    make install
    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
    popd
;;

dejagnu)
    reinstall "${1}"
    push_into "${1}"

    mkdir -v build
    pushd       build
    
    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi 
    make check
    make install
    install -v -dm755  /usr/share/doc/dejagnu-1.6.3
    install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
    
    popd

    popd
;;


pkgconf)
    reinstall "${1}"
    push_into "${1}"
    
   ./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.1.1 

    
    safe_make
    make install

    ln -sv pkgconf   /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

    popd
;;

binutils)
    reinstall "${1}"
    push_into "${1}"

    mkdir -v build
    pushd       build

    ../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

    safe_make tooldir=/usr
    make -k check
    
    grep '^FAIL:' $(find -name '*.log')
    make tooldir=/usr install

    rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

    popd
    popd
;;

gmp)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

    
    safe_make
    make html

    make check 2>&1 | tee gmp-check-log

    awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
    make install
    make install-html

    popd
;;

mpfr)
    reinstall "${1}"
    push_into "${1}"
    
    ./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1


    safe_make
    make install
    make check
    make install
    make install-html 
    

    popd
;;
mpc)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

    safe_make
    make html
    make check
    make install
    make install-html

    popd
;;

attr)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

    safe_make
    make check
    make install


    popd
;;

acl)
    reinstall "${1}"
    push_into "${1}"

   ./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2 

    safe_make
    make install

    popd
;;

libcap)
    reinstall "${1}"
    push_into "${1}"

    sed -i '/install -m.*STA/d' libcap/Makefile
    safe_make prefix=/usr lib=lib

    make test
    make prefix=/usr lib=lib install


    popd
;;

libxcrypt)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

    safe_make
    make check

    make install

    popd
;;

shadow)
    reinstall "${1}"
    push_into "${1}"

    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

    sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs    

    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc   \
                --disable-static    \
                --with-{b,yes}crypt \
                --without-libbsd    \
                --with-group-name-max-length=32

    safe_make

    make exec_prefix=/usr install
    make -C man install-man

    pwconv
    grpconv

    mkdir -p /etc/default
    useradd -D --gid 999


    popd
;;

gcc)
    reinstall "${1}"
    push_into "${1}"

    case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
     ;;
    esac

    mkdir -v build
    pushd       build

    ../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib
    
    
    safe_make
    ulimit -s 32768

    chown -R tester .
    su tester -c "PATH=$PATH make -k check"

    ../contrib/test_summary
    make install

    chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/13.2.0/include{,-fixed}


    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1

    ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/


    echo 'int main(){}' > dummy.c
    cc dummy.c -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'

    grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
    grep -B4 '^ /usr/include' dummy.log
    grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " dummy.log
    grep found dummy.log
    rm -v dummy.c a.out dummy.log

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
    



    

    
    popd

    popd
;;

ncurses)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --enable-widec          \
            --with-pkg-config-libdir=/usr/lib/pkgconfig


    safe_make
    make DESTDIR=$PWD/dest install
    install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib
    rm -v  dest/usr/lib/libncursesw.so.6.4
    sed -e 's/^#if.*XOPEN.*$/#if 1/' \
        -i dest/usr/include/curses.h
    cp -av dest/* /     

    for lib in ncurses form panel menu ; do
        ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
    done

    ln -sfv libncursesw.so /usr/lib/libcurses.so
    cp -v -R doc -T /usr/share/doc/ncurses-6.4-20230520

    


    popd

;;

sed)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr
    safe_make
    make html

    chown -R tester .
    su tester -c "PATH=$PATH make check"

    make install
    install -d -m755           /usr/share/doc/sed-4.9
    install -m644 doc/sed.html /usr/share/doc/sed-4.9

    popd
;;

psmisc)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr
    safe_make

    make check

    make install

    popd
;;

gettext)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.22.4

    safe_make

    make check
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so

    

    popd
;;

bison)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
    safe_make

    make check
    make install

    popd
;;


grep)
    reinstall "${1}"
    push_into "${1}"

    sed -i "s/echo/#echo/" src/egrep.sh
    ./configure --prefix=/usr

    safe_make
    make check
    make install
    popd
;;

bash)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.21

    safe_make

    chown -R tester .

su -s /usr/bin/expect tester << EOF
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

make install
exec /usr/bin/bash --login


    popd
;;

libtool)
    reinstall "${1}"
    push_into "${1}"
    
    ./configure --prefix=/usr
    safe_make

    make -k check
    make install
    rm -fv /usr/lib/libltdl.a



    popd
;;

gdbm)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

    safe_make
    make check
    make install

    
    popd
;;

gperf)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    safe_make

    make -j1 check
    make install

    popd
;;

expat)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.0
    

    safe_make

    make check
    make install
    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.0


    popd
;;
inetutils)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

    safe_make

    make check
    make install
    mv -v /usr/{,s}bin/ifconfig


    popd
;;

less)
    reinstall "${1}"
    push_into "${1}"

    ./configure --prefix=/usr --sysconfdir=/etc
    
    safe_make
    make check
    make install


    popd
;;

perl)
    reinstall "${1}"
    push_into "${1}"

    export BUILD_ZLIB=False
    export BUILD_BZIP2=0

    sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.38/core_perl      \
             -Darchlib=/usr/lib/perl5/5.38/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.38/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.38/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads

    safe_make
    TEST_JOBS=$(nproc) make test_harness
    make install
    unset BUILD_ZLIB BUILD_BZIP2
    
    popd
;;

XML-Parser)
    reinstall "${1}"
    push_into "${1}"

    perl Makefile.PL
    safe_make

    make test 
    make install


    popd
;;

intltool)
echo ok
;;


esac
}


[[ -n "${*}" ]] && "${@}"
