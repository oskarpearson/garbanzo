#!/bin/bash

set -e
set -x
set -o pipefail

TEMPLATE_DIR=/opt/garbanzo/templates

PRIVATE_HOSTNAME=$(cat /opt/garbanzo/etc/private_hostname)
PRIVATE_IP=$(cat /opt/garbanzo/etc/private_ip)
ROUTE53_ZONE_ID=$(cat /opt/garbanzo/etc/route53_zone_id)
WORK_DIR=$(mktemp -d /tmp/bootstrap_route53-XXXXXXXXXXX)

sed \
  -e "s#\${FQDN}#${FQDN}#" \
  -e "s#\${PRIVATE_HOSTNAME}#${PRIVATE_HOSTNAME}#" \
  -e "s#\${PRIVATE_IP}#${PRIVATE_IP}#" \
  ${TEMPLATE_DIR}/route53_private_ip_update.json.tmpl > ${WORK_DIR}/route53_private_ip_update.json

aws route53 change-resource-record-sets --hosted-zone-id ${ROUTE53_ZONE_ID} --change-batch file://${WORK_DIR}/route53_private_ip_update.json > ${WORK_DIR}/response.json

# Wait for the change to occur, otherwise we'll start kicking off other scripts
# when DNS hasn't changed yet
CHANGE_ID=$(jq -r .ChangeInfo.Id < ${WORK_DIR}/response.json)
echo "Waiting for DNS change to propagate..."
aws route53 wait resource-record-sets-changed --id ${CHANGE_ID}

rm -rf ${WORK_DIR}
