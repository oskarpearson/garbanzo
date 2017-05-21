#!/bin/bash

# Thanks for some of this go to
# https://github.com/weaveworks/kubernetes-ami/blob/master/packer/prepare-ami.sh

set -x
set -e
set -o pipefail

KUBE_APT_KEY='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
KUBE_APT_REPO='deb http://apt.kubernetes.io/ kubernetes-xenial main'

BASE_PACKAGES="python python-pip"
KUBE_PACKAGES="docker.io kubelet kubeadm kubectl kubernetes-cni"

export DEBIAN_FRONTEND=noninteractive

# Add the Kubernetes apt repo
curl --silent ${KUBE_APT_KEY} | apt-key add -
echo ${KUBE_APT_REPO} > /etc/apt/sources.list.d/kubernetes.list

# Save release version in the same path as
# https://github.com/weaveworks/kubernetes-ami/blob/master/packer/prepare-ami.sh
echo "${kubernetes_release_tag}" > /etc/kubernetes_community_ami_version

# Install required packages
apt-get update
apt-get -o "Dpkg::Options::=--force-confnew" -qy dist-upgrade
apt-get -o "Dpkg::Options::=--force-confnew" -qy install ${BASE_PACKAGES} ${KUBE_PACKAGES}

# If we need to, reboot so that we are on the latest kernel
if [ -f /var/run/reboot-required ]; then
  reboot
fi
