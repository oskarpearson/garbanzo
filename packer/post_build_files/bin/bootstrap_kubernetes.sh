#!/bin/bash

set -e
set -x
set -o pipefail

TEMPLATE_DIR=/opt/garbanzo/templates

CLUSTER_NAME=$(cat /opt/garbanzo/etc/cluster_name)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)
PRIVATE_IP=$(cat /opt/garbanzo/etc/private_ip)
MASTER_COUNT=$(cat /opt/garbanzo/etc/master_count)
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
  ETCD_CLUSTER_HOSTS[i]="https://master-${i}-priv.${DOMAIN_NAME}:2380"
done
ETCD_CLUSTER_LIST=$(IFS=, ; echo "${ETCD_CLUSTER_HOSTS[*]}")

aws s3 cp "s3://${SSL_KEY_BUCKET}/token.csv" /var/lib/kubernetes/token.csv
chown root:root /var/lib/kubernetes/token.csv
chmod 600 /var/lib/kubernetes/token.csv

################################################################################
# kube-apiserver
################################################################################
sed \
  -e "s#\${ETCD_CLUSTER_LIST}#${ETCD_CLUSTER_LIST}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  -e "s#\${SSL_DIR}#${SSL_DIR}#" \
  ${TEMPLATE_DIR}/kube-apiserver.service.tmpl > /etc/systemd/system/kube-apiserver.service

# start and check API server status
echo systemctl daemon-reload
echo systemctl enable kube-apiserver
echo systemctl start kube-apiserver
echo systemctl status kube-apiserver --no-pager -l


################################################################################
# kube-controller-manager
################################################################################

sed \
  -e "s#\${CLUSTER_NAME}#${CLUSTER_NAME}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  -e "s#\${SSL_DIR}#${SSL_DIR}#" \
  ${TEMPLATE_DIR}/kube-controller-manager.service.tmpl > /etc/systemd/system/kube-controller-manager.service

echo systemctl daemon-reload
echo systemctl enable kube-controller-manager
echo systemctl start kube-controller-manager
echo systemctl status -l kube-controller-manager --no-pager -l
#
# ################################################################################
# # kube-scheduler
# ################################################################################
#
sed \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  ${TEMPLATE_DIR}/kube-scheduler.service.tmpl > /etc/systemd/system/kube-scheduler.service
#
echo systemctl daemon-reload
echo systemctl enable kube-scheduler
echo systemctl start kube-scheduler
echo systemctl status kube-scheduler --no-pager -l
