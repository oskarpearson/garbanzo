#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Need the Kubernetes docker container version as the first parameter"
  exit 1
fi

KUBE_VERSION="$1"
echo "Pre-fetching Kubernetes container version ${KUBE_VERSION}"

# Thanks for some of this go to
# https://github.com/weaveworks/kubernetes-ami/blob/master/packer/prepare-ami.sh

set -x
set -e
set -o pipefail

# Wait for docker to be up - this script can kick off before docker has started
# on the host

# Pull docker containers in parallel. This list of containers is the same
# as https://github.com/weaveworks/kubernetes-ami/blob/master/packer/prepare-ami.sh
# except I've removed the weaveworks containers
FAILURES=0
docker pull "gcr.io/google_containers/etcd-amd64:3.0.17" &
docker pull "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1" &
docker pull "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1" &
docker pull "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1" &
docker pull "gcr.io/google_containers/kube-apiserver-amd64:${KUBE_VERSION}" &
docker pull "gcr.io/google_containers/kube-controller-manager-amd64:${KUBE_VERSION}" &
docker pull "gcr.io/google_containers/kube-proxy-amd64:${KUBE_VERSION}" &
docker pull "gcr.io/google_containers/kube-scheduler-amd64:${KUBE_VERSION}" &
docker pull "gcr.io/google_containers/pause-amd64:3.0" &

# Wait for jobs to finish and check for any failures
for job in `jobs -p`; do
    echo Waiting for $job
    wait $job || let "FAILURES+=1"
done

if [ "$FAILURES" -gt "0" ]; then
  echo Fetching docker images failed
  exit 1
fi
