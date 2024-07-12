source_dir() {
    local tar_file=$(grep "^${1} " "${cur}/resources/packages.txt" | awk '{print $2}')

    pushd "${LFS}/sources" >/dev/null



    popd
}
 
__reinstall() {
    pushd "${LFS}/sources"

    local url=$(cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $3}')

    [[ -z "${url}" ]] && echo "url not exists" && exit 1
    [[ -f `basename ${url}` ]] || wget "${url}"

    
    local ver=$(cat "${cur}/packages.csv" | grep "^${1}" | awk '{print $2}')
    local src_dir=$(source_dir "${1}")
    
    if [[ "${1}" == tcl ]]; then
        src_dir="tcl8.6.13"
    fi

    [[ -d "${src_dir}" ]] && rm -rf "${src_dir}"
    tar -xf `basename ${url}` -C .

    ! [[ -d "${src_dir}" ]]  && echo "extract failed: ${src_dir} not exists" && exit 1

    # check if we need push
    local patch_url=$(cat "${cur}/patch.csv" | grep "^${1}" | awk '{print $2}')

    if [[ -n "${patch_url}" ]]; then
        [[ -f `basename ${patch_url}` ]] || wget "${patch_url}"
        pushd "${src_dir}"

        echo "patch ${src_dir} with $(basename ${patch_url})"
        ! [[ -f "../$(basename ${patch_url})" ]] && echo patch file not found && exit 1

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
        echo mv "${src}" "${dst}/${x}"
        mv "${src}" "${dst}/${x}"
    done
}

push_into() {
    pushd "${LFS}/sources" >/dev/null
    local dst=$(source_dir "${1}")

    ! [[ -d "${dst}" ]] && echo "${dst} not found" && exit 1
    popd >/dev/null

    pushd "${LFS}/sources/${dst}"
}

# handle make error: retry it!
safe_make() {
    while ! make "${@}" "-j$(nproc)"; do
        local current_dir=`pwd`
        echo "make ${PWD} failed wait 3 seconds then continue"
        sleep 3
    done
}

