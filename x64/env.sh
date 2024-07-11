export LFS=/mnt/lfs

check_lfs() {
! [[ -d "${LFS}" ]] && echo "ERROR: LFS not mounted" && exit 1
}
