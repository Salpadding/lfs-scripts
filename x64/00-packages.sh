#!/bin/bash
# download packages
cur=`dirname "${0}"`
cur=$(cd "${cur}"; pwd)


package_checksums() {
    xq -m -q 'dd > p:nth-child(3) code' ${cur}/resources/packages.html
}


patch_checksums() {
    xq -m -q 'dd > p:nth-child(2) code' ${cur}/resources/patches.html
}

packages() {
    xq -q 'dd p:nth-child(2) a' -m ${cur}/resources/packages.html
}

patches() {
    xq -q 'dd p:nth-child(1) a' -m ${cur}/resources/patches.html
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

# e.g. transfer root@192.168.1.1:/mnt/lfs/sources
transfer() {
    pushd "${cur}/../sources" >/dev/null

    find . -maxdepth 1 -type f | while read -r file; do
        rsync -azvp "${file}" "${1}/${file}"
    done

    popd
}

[[ -n "${*}" ]] && "${@}"

