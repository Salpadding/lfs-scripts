#!/bin/bash

cur=`dirname "${0}"`
cur=`cd "${cur}"; pwd`

pushd "${cur}"


source "env.sh"

[[ -z "${LFS}" ]] && echo "ERROR: LFS environment not set " && exit 1

! [[ -d "${LFS}" ]] && echo "ERROR: LFS not mounted" && exit 1


mkdir -p "${LFS}/sources"

popd
