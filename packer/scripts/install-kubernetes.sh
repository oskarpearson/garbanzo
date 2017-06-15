#!/bin/bash

set -x
set -e
set -o pipefail

if [ -z "${1}" ]; then
  echo "Need a kubernetes version number as the first command-line parameter"
  exit 1
fi

if [ -z "${2}" ]; then
  echo "Need a CNI release file as the second command-line parameter"
  exit 1
fi

FILE_LIST="kube-apiserver kube-controller-manager kube-scheduler kubectl kube-proxy kubelet"

# download kubernetes binaries
for FILE in ${FILE_LIST}; do
  curl -sSL -o /usr/local/bin/${FILE} https://storage.googleapis.com/kubernetes-release/release/${1}/bin/linux/amd64/${FILE}
  chown root:root /usr/local/bin/${FILE}
  chmod 755 /usr/local/bin/${FILE}
done


# FIXME - move this to packer build time
mkdir -p /opt/cni
curl -sSL https://storage.googleapis.com/kubernetes-release/network-plugins/${2}.tar.gz | tar -C /opt/cni -zxvf -
