#!/bin/bash

set -x
set -e
set -o pipefail

if [ -z "${1}" ]; then
  echo "Need a kubernetes version number as the first command-line parameter"
  exit 1
fi

FILE_LIST="kube-apiserver kube-controller-manager kube-scheduler kubectl"

# download kubernetes binaries
for FILE in ${FILE_LIST}; do
  curl -sSL -o /usr/local/bin/${FILE} https://storage.googleapis.com/kubernetes-release/release/${1}/bin/linux/amd64/${FILE}
  chown root:root /usr/local/bin/${FILE}
  chmod 755 /usr/local/bin/${FILE}
done
