#! /bin/bash

set -x
set -e
set -o pipefail

# Set hostname
echo "${hostname}.${domain_name}" > /etc/hostname
hostname -F /etc/hostname

# gather running context
INSTANCE_ID=$(curl -sS http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -sS http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

# Write the master information to files
echo "${cluster_name}" > /opt/garbanzo/etc/cluster_name
echo "${domain_name}" > /opt/garbanzo/etc/domain_name
echo "${ssl_key_bucket}" > /opt/garbanzo/etc/ssl_key_bucket

echo "$${INSTANCE_ID}" > /opt/garbanzo/etc/instance_id
echo "$${PRIVATE_IP}" > /opt/garbanzo/etc/private_ip

chown -R root:root /opt/garbanzo/etc/
chmod 700 /opt/garbanzo/etc/
chmod 600 /opt/garbanzo/etc/*

echo FIXME - modules/workers/user_data.tpl
# /opt/garbanzo/bin/bootstrap_worker.sh
