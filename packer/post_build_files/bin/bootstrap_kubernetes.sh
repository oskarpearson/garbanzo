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
  ETCD_CLUSTER_HOSTS[i]="https://master-${i}-priv.${DOMAIN_NAME}:2379"
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
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver --no-pager -l

echo "Waiting for API to come up before trying to start other services..."
sleep 10

################################################################################
# kube-controller-manager
################################################################################

sed \
  -e "s#\${CLUSTER_NAME}#${CLUSTER_NAME}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  -e "s#\${SSL_DIR}#${SSL_DIR}#" \
  ${TEMPLATE_DIR}/kube-controller-manager.service.tmpl > /etc/systemd/system/kube-controller-manager.service
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
systemctl status kube-controller-manager --no-pager -l
#
# ################################################################################
# # kube-scheduler
# ################################################################################
#
sed \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  ${TEMPLATE_DIR}/kube-scheduler.service.tmpl > /etc/systemd/system/kube-scheduler.service
#
systemctl daemon-reload
systemctl enable kube-scheduler
systemctl start kube-scheduler
systemctl status kube-scheduler --no-pager -l


################################################################################
# Create cluster role bindings
################################################################################

# Note that we only create these if they don't already exist. We also don't
# worry about return status (using '|| true') since on first boot the masters
# may try add the bindings at exactly the same time, and we don't want to
# consider that race condition to be a failure case

# Wait at least 10 seconds for everything to come up before continuing
sleep $[($RANDOM % 10 + 10)]

# Add a user binding and group binding; both seem to be required
# Both the user 'kubelet-bootstrap' and group 'kubelet-bootstrap'
# refer to the user/group stored the token.csv file

echo "Creating bootstrapper cluster bindings. Ignore errors about binding"
echo "not already existing below."

if ! kubectl get clusterrolebinding kubelet-node-bootstrapper-user-binding; then
  kubectl create clusterrolebinding kubelet-node-bootstrapper-user-binding \
      --clusterrole=system:node-bootstrapper \
      --user=kubelet-bootstrap
fi

# kubelet-bootstrap refers to the group in the associated token.csv file
if ! kubectl get clusterrolebinding kubelet-node-bootstrapper-group-binding; then
  kubectl create clusterrolebinding kubelet-node-bootstrapper-group-binding \
    --clusterrole=system:node-bootstrapper \
    --group=system:kubelet-bootstrap
fi
