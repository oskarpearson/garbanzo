#!/bin/bash


set -e
set -x
set -o pipefail

TEMPLATE_DIR=/opt/garbanzo/templates

KUBELET_DIR=/var/lib/kubelet
KUBE_PROXY_DIR=/var/lib/kube-proxy
KUBERNETES_DIR=/var/lib/kubernetes

CLUSTER_NAME=$(cat /opt/garbanzo/etc/cluster_name)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)
SSL_DIR=/opt/garbanzo/ssl
SSL_KEY_BUCKET=$(cat /opt/garbanzo/etc/ssl_key_bucket)

for dir in ${KUBELET_DIR} ${KUBE_PROXY_DIR} ${KUBERNETES_DIR}; do
  if [ ! -e ${dir} ]; then
    mkdir -p ${dir}
  fi
  chown root:root ${dir}
  chmod 700 ${dir}
done

################################################################################
# Copy Config files from S3 bucket
################################################################################

for FILENAME in ca.pem; do
  aws s3 cp "s3://${SSL_KEY_BUCKET}/${FILENAME}" ${SSL_DIR}/${FILENAME}
  chown root:root ${SSL_DIR}/${FILENAME}
  chmod 600 ${SSL_DIR}/${FILENAME}
done

for FILENAME in bootstrap.kubeconfig; do
  aws s3 cp "s3://${SSL_KEY_BUCKET}/${FILENAME}" ${KUBELET_DIR}/${FILENAME}
  chown root:root ${KUBELET_DIR}/${FILENAME}
  chmod 600 ${KUBELET_DIR}/${FILENAME}
done

for FILENAME in kube-proxy.kubeconfig; do
  aws s3 cp "s3://${SSL_KEY_BUCKET}/${FILENAME}" ${KUBE_PROXY_DIR}/${FILENAME}
  chown root:root ${KUBE_PROXY_DIR}/${FILENAME}
  chmod 600 ${KUBE_PROXY_DIR}/${FILENAME}
done

################################################################################
# kubeconfig
################################################################################
sed \
  -e "s#\${SSL_DIR}#${SSL_DIR}#" \
  ${TEMPLATE_DIR}/kubelet.service.tmpl > /etc/systemd/system/kubelet.service

systemctl daemon-reload
systemctl enable kubelet
systemctl start kubelet
systemctl status kubelet --no-pager -l

################################################################################
# kube-proxy
################################################################################

# No substitutions - but keep the template in the same place for consistency
cat ${TEMPLATE_DIR}/kube-proxy.service.tmpl > /etc/systemd/system/kube-proxy.service

systemctl daemon-reload
systemctl enable kube-proxy
systemctl start kube-proxy
systemctl status kube-proxy --no-pager -l
