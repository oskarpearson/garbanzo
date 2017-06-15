#! /bin/bash

set -x
set -e
set -o pipefail

# gather running context
INSTANCE_ID=$(curl -sS http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -sS http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -sS http://169.254.169.254/latest/meta-data/public-ipv4)

# Set hostname
echo "worker-$${INSTANCE_ID}.${domain_name}" > /etc/hostname
hostname -F /etc/hostname

sed -i -e "s/^127.0.0.1.*/127.0.0.1 localhost worker-$${INSTANCE_ID} worker-$${INSTANCE_ID}.${domain_name}/" /etc/hosts

# Write the master information to files
echo "${cluster_name}" > /opt/garbanzo/etc/cluster_name
echo "worker-$${INSTANCE_ID}-priv.${domain_name}" > /opt/garbanzo/etc/private_hostname
echo "${domain_name}" > /opt/garbanzo/etc/domain_name
echo "${ssl_key_bucket}" > /opt/garbanzo/etc/ssl_key_bucket

echo "$${PUBLIC_IP}" > /opt/garbanzo/etc/public_ip
echo "$${INSTANCE_ID}" > /opt/garbanzo/etc/instance_id
echo "$${PRIVATE_IP}" > /opt/garbanzo/etc/private_ip

chown -R root:root /opt/garbanzo/etc/
chmod 700 /opt/garbanzo/etc/
chmod 600 /opt/garbanzo/etc/*

echo FIXME - modules/workers/user_data.tpl
# /opt/garbanzo/bin/bootstrap_worker.sh

# assume restricted running role
# FIXME BOOTSTRAP_PROFILE_ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations --region $${REGION} --filters Name=instance-id,Values=$${INSTANCE_ID} | jq -r .IamInstanceProfileAssociations[0].AssociationId)
# FIXME aws ec2 replace-iam-instance-profile-association --region $${REGION} --iam-instance-profile Arn=${running_profile_arn} --association-id $${BOOTSTRAP_PROFILE_ASSOCIATION_ID}
