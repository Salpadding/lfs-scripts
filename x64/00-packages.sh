#!/bin/bash
# download packages
cur=`dirname "${0}"`
cur=$(cd "${cur}"; pwd)


package_checksums() {
    xq -m -q 'dd p:contains("MD5 sum:") code' ${cur}/resources/packages.html
}


patch_checksums() {
    xq -m -q 'dd p:contains("MD5 sum:") code' ${cur}/resources/patches.html
}

packages() {
    xq -q 'dd p:contains("Download:") a' -m ${cur}/resources/packages.html
}

patches() {
    xq -q 'dd p:contains("Download:") a' -m ${cur}/resources/patches.html
}

mirror_of() {
    grep "^${1}" ${cur}/resources/mirrors.txt | awk '{print $2}'
}

check_all() {
    local packages=(`packages`)
    local sums=(`package_checksums`)
    packages+=(`patches`)
    sums+=(`patch_checksums`)

    pushd "${cur}/../sources" >/dev/null

    while [[ "${i}" -lt "${#packages[@]}" ]]; do
        local p="${packages[${i}]}" 
        local b="$(basename ${p})"
        local sum=$(md5sum "${b}" 2>&1 | awk '{print $1}')

        ! [[ "${sum}" == "${sums[${i}]}" ]] &&
            echo "check sum error for ${b} ${sum} <> ${sums[${i}]}" 

        let i++
    done

    popd >/dev/null
}

download_all() {
    local packages=(`packages`)
    packages+=(`patches`)

    let i=0

    while [[ "${i}" -lt "${#packages[@]}" ]]; do
        local p="${packages[${i}]}" 
        local b="$(basename ${p})"
        local m="$(mirror_of ${b})"
        [[ -n "${m}" ]] && p="${m}"

        pushd "${cur}/../sources" >/dev/null

        if ! [[ -f "${b}" ]]; then
            wget "${p}"
        fi

        popd >/dev/null
        let i++
    done
}

gen_packages_txt() {
    local packages=(`packages`)

    let i=0

    while [[ "${i}" -lt "${#packages[@]}" ]]; do
        local p="${packages[${i}]}" 
        local b="$(basename ${p})"
        local name=$(echo "${b}" | awk -F '-' '{print $1}')
        local dir=

        if echo $b | grep -q html.tar ;then 
            let i++
            continue
        fi
        case "${b}" in
            expect5.45.4.tar.gz)
            name=expect
            ;;
            tcl8.6.13-src.tar.gz)
            name=tcl
            ;;
            man-db-2.12.0.tar.xz)
            name=man-db
            ;;
            man-pages-6.06.tar.xz)
            name=man-pages
            ;;
            util-linux-2.39.3.tar.xz)
            name=util-linux
            ;;
            systemd-man-pages-255.tar.xz)
            name=systemd-man-pages
            ;;
            XML-Parser-2.47.tar.gz)
            name=XML-Parser
            ;;
        esac

        pushd "${cur}/../sources" >/dev/null
            dir=$(tar -tf "${b}" | head -n1 | awk -F / '{print $1}')
        popd >/dev/null

        echo "${name} ${b} ${dir}"
        let i++
    done
    echo "udev-lfs systemd-255.tar.gz systemd-255"
}

# e.g. transfer root@192.168.1.1:/mnt/lfs/sources
transfer() {
    pushd "${cur}/../sources" >/dev/null

    find . -maxdepth 1 -type f | while read -r file; do
        rsync -azvp "${file}" "${1}/${file}"
    done

    popd
}

[[ -n "${*}" ]] && "${@}"

