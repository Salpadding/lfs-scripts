source_dir() {
    grep "^${1} " "${cur}/resources/packages.txt" | sed -n '$p' | awk '{print $3}' 
}
 
__reinstall() {
    pushd "${LFS}/sources" >/dev/null

    local zip=$(grep "^${1} " "${cur}/resources/packages.txt" | sed -n '$p' | awk '{print $2}')

    [[ -z "${zip}" ]] && echo "${1} not found in packages.txt" && exit 1
    ! [[ -f "${zip}" ]] && echo "${1} not downloaded" && exit 1
    
    local src_dir=$(source_dir "${1}")
    [[ -d "${src_dir}" ]] && rm -rf "${src_dir}"
    tar -xf "${zip}" -C .

    ! [[ -d "${src_dir}" ]]  && echo "extract failed: ${src_dir} not exists" && exit 1

    # check if we need patch
    local patch_url=$(grep "^${1} " "${cur}/resources/patches.txt" | awk '{print $2}')

    if [[ -z "${patch_url}" ]]; then
        popd >/dev/null
        return
    fi

    local patch_file=$(basename "${patch_url}")
    ! [[ -f "${patch_file}" ]] && echo "patch file ${patch_file} not download" && exit 1

    pushd "${src_dir}" >/dev/null
        echo "patch ${src_dir} with ${patch_file}"
        patch -Np1 -i "../${patch_file}"
    popd >/dev/null

    popd >/dev/null
}

reinstall() {
    for p in "${@}"; do
        __reinstall "${p}"
    done
}

move_into() {
    pushd "${LFS}/sources" >/dev/null
        local dst=
        for x in "${@}"; do
            local dir=$(source_dir "${x}")
            [[ -z "${dst}" ]] && dst="${dir}" && continue
            mv -v "${dir}" "${dst}/${x}"
        done
    popd >/dev/null
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

