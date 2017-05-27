#!/bin/bash

set -e
set -x
set -o pipefail

ETCD_VERSION=v3.1.8

DOWNLOAD_URL=https://github.com/coreos/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz

INSTALL_DIR=$(mktemp -d /tmp/install-etcd-systemd-XXXXXXXXXXX)

cd ${INSTALL_DIR}

curl -sSL -O ${DOWNLOAD_URL}
tar zxvf etcd-${ETCD_VERSION}-linux-amd64.tar.gz
mv etcd-${ETCD_VERSION}-linux-amd64/etcd* /usr/bin/

cd /
rm -rf ${INSTALL_DIR}
