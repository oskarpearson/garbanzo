#!/bin/bash

set -e
set -x
set -o pipefail

TEMPLATE_DIR=/opt/garbanzo/templates

CLUSTER_NAME=$(cat /opt/garbanzo/etc/cluster_name)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)
SSL_DIR=/opt/garbanzo/ssl
SSL_KEY_BUCKET=$(cat /opt/garbanzo/etc/ssl_key_bucket)

# download the bootstrap token
if [ ! -e /var/lib/kubernetes ]; then
  mkdir -p /var/lib/kubernetes/
fi
chown root:root /var/lib/kubernetes
chmod 700 /var/lib/kubernetes

declare -a ETCD_CLUSTER_HOSTS
for i in $(seq 1 $MASTER_COUNT); do
  ETCD_CLUSTER_HOSTS[i]="https://master-${i}-priv.${DOMAIN_NAME}:2379"
done
ETCD_CLUSTER_LIST=$(IFS=, ; echo "${ETCD_CLUSTER_HOSTS[*]}")

aws s3 cp "s3://${SSL_KEY_BUCKET}/token.csv" /var/lib/kubernetes/token.csv
chown root:root /var/lib/kubernetes/token.csv
chmod 600 /var/lib/kubernetes/token.csv
