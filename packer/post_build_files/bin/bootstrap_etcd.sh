#!/bin/bash

set -e
set -x
set -o pipefail

TEMPLATE_DIR=/opt/garbanzo/templates

CLUSTER_NAME=$(cat /opt/garbanzo/etc/cluster_name)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)
INSTANCE_ID=$(cat /opt/garbanzo/etc/instance_id)
MASTER_ID=$(cat /opt/garbanzo/etc/master_id)
MASTER_COUNT=$(cat /opt/garbanzo/etc/master_count)
PRIVATE_IP=$(cat /opt/garbanzo/etc/private_ip)
PRIVATE_HOSTNAME=$(cat /opt/garbanzo/etc/private_hostname)

if [ ! -d /etc/etcd/ ]; then
  mkdir -p /etc/etcd/
fi

chmod 700 /etc/etcd
chown -R root:root /etc/etcd/
cp /opt/garbanzo/ssl/ca.pem /opt/garbanzo/ssl/local-server.pem /opt/garbanzo/ssl/local-server-key.pem /etc/etcd/
chown -R root:root /etc/etcd/*.pem
chmod 600 /etc/etcd/*.pem

declare -a ETCD_CLUSTER_HOSTS
for i in $(seq 1 $MASTER_COUNT); do
  ETCD_CLUSTER_HOSTS[i]="master-${i}=https://master-${i}-priv.${DOMAIN_NAME}:2380"
done
ETCD_CLUSTER_LIST=$(IFS=, ; echo "${ETCD_CLUSTER_HOSTS[*]}")

echo "Full cluster list: ${JOINED_ETCD_CLUSTER_LIST}"

sed \
  -e "s#\${MASTER_ID}#${MASTER_ID}#" \
  -e "s#\${ETCD_CLUSTER_LIST}#${ETCD_CLUSTER_LIST}#" \
  -e "s#\${PRIVATE_HOSTNAME}#${PRIVATE_HOSTNAME}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  -e "s#\${CLUSTER_NAME}#${CLUSTER_NAME}#" \
  ${TEMPLATE_DIR}/etcd.service.tmpl > /etc/systemd/system/etcd.service

echo "After service creation:"
cat /etc/systemd/system/etcd.service

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
sleep 2
systemctl status etcd --no-pager -l
