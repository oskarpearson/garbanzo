#!/bin/bash

set -e
set -x
set -o pipefail

if [ -z "${1}" ]; then
  echo "Need a etcd version number as the first command-line parameter"
  exit 1
fi

DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download/${1}/etcd-${1}-linux-amd64.tar.gz

INSTALL_DIR=$(mktemp -d /tmp/install-etcd-systemd-XXXXXXXXXXX)

cd ${INSTALL_DIR}

curl -sSL -O ${DOWNLOAD_URL}
tar zxvf etcd-${1}-linux-amd64.tar.gz
mv etcd-${1}-linux-amd64/etcd* /usr/bin/

cd /
rm -rf ${INSTALL_DIR}
