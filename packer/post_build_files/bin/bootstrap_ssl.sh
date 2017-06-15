#!/bin/bash

set -e
set -x
set -o pipefail

umask 077

TEMPLATE_DIR=/opt/garbanzo/templates
SSL_DIR=/opt/garbanzo/ssl

PRIVATE_HOSTNAME=$(cat /opt/garbanzo/etc/private_hostname)
PRIVATE_IP=$(cat /opt/garbanzo/etc/private_ip)
PUBLIC_IP=$(cat /opt/garbanzo/etc/public_ip)
SSL_KEY_BUCKET=$(cat /opt/garbanzo/etc/ssl_key_bucket)
DOMAIN_NAME=$(cat /opt/garbanzo/etc/domain_name)

if [ -f /opt/garbanzo/etc/master_id ]; then
  PUBLIC_HOSTNAME="api.${DOMAIN_NAME}"
else
  PUBLIC_HOSTNAME=$(cat /etc/hostname)
fi

if [ ! -d ${SSL_DIR} ]; then
  mkdir -p ${SSL_DIR}
fi

chown -R root:root ${SSL_DIR}
chmod 700 ${SSL_DIR}

for FILENAME in ca.pem ca-key.pem ca-config.json; do
  aws s3 cp "s3://${SSL_KEY_BUCKET}/${FILENAME}" ${SSL_DIR}/${FILENAME}
done

sed \
  -e "s#\${PUBLIC_HOSTNAME}#${PUBLIC_HOSTNAME}#" \
  -e "s#\${PRIVATE_HOSTNAME}#${PRIVATE_HOSTNAME}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  -e "s#\${PUBLIC_IP}#${PUBLIC_IP}#" \
  ${TEMPLATE_DIR}/local-server-csr.json.tmpl > ${SSL_DIR}/local-server-csr.json

cd ${SSL_DIR}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  local-server-csr.json | cfssljson -bare local-server
