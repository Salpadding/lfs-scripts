get_ver() {
    cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $2}'
}

get_url() {
    cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $3}'
}

 
__reinstall() {
    pushd "${LFS}/sources"

    local url=$(cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $3}')

    [[ -z "${url}" ]] && echo "url not exists" && exit 1
    [[ -f `basename ${url}` ]] || wget "${url}"

    
    local ver=$(cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $2}')

    [[ -d "${1}-${ver}" ]] && rm -rf "${1}-${ver}"
    tar -xf `basename ${url}` -C .

    ! [[ -d "${1}-${ver}" ]]  && echo "extract failed: ${1}-${ver} not exists" && exit 1

    # check if we need push
    local patch_url=$(cat "${cur}/patch.csv" | grep "^${1}" | awk '{print $2}')

    if [[ -n "${patch_url}" ]]; then
        [[ -f `basename ${patch_url}` ]] || wget "${patch_url}"
        pushd "${1}-${ver}"

        echo "patch ${1}-${ver} with $(basename ${patch_url})"
        patch -Np1 -i "../$(basename ${patch_url})"
        popd
    fi


    popd
}

reinstall() {
    for p in "${@}"; do
        __reinstall "${p}"
    done
}

move_into() {
    pushd "${LFS}/sources"
    local dst=
    for x in "${@}"; do
        [[ -z "${dst}" ]] && dst="${x}-$(get_ver ${x})" && continue
        local src="${x}-$(get_ver ${x})" 
        mv "${src}" "${dst}/${x}"
    done
}

push_into() {
    pushd "${LFS}/sources" >/dev/null
    local dst="${1}-$(get_ver ${1})"

    ! [[ -d "${dst}" ]] && echo "${dst} not found" && exit 1
    popd >/dev/null

    pushd "${LFS}/sources/${dst}"
}

