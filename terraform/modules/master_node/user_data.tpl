#! /bin/bash

set -x
set -e
set -o pipefail

# gather running context
INSTANCE_ID=$(curl -sS http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -sS http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
PRIVATE_IP=$(curl -sS http://169.254.169.254/latest/meta-data/local-ipv4)

# Set hostname
echo "${hostname}.${domain_name}" > /etc/hostname
hostname -F /etc/hostname

sed -i -e "s/^127.0.0.1.*/127.0.0.1 localhost ${hostname} ${hostname}.${domain_name}/" /etc/hosts

# Write the master information to files
echo "${cluster_name}" > /opt/garbanzo/etc/cluster_name
echo "${hostname}-priv.${domain_name}" > /opt/garbanzo/etc/private_hostname
echo "${domain_name}" > /opt/garbanzo/etc/domain_name
echo "${master_count}" > /opt/garbanzo/etc/master_count
echo "${master_id}" > /opt/garbanzo/etc/master_id
echo "${ssl_key_bucket}" > /opt/garbanzo/etc/ssl_key_bucket
echo "${elastic_ip}" > /opt/garbanzo/etc/public_ip
echo "${route53_zone_id}" > /opt/garbanzo/etc/route53_zone_id

echo "$${INSTANCE_ID}" > /opt/garbanzo/etc/instance_id
echo "$${PRIVATE_IP}" > /opt/garbanzo/etc/private_ip

chown -R root:root /opt/garbanzo/etc/
chmod 700 /opt/garbanzo/etc/
chmod 600 /opt/garbanzo/etc/*

# Attach elastic IP
aws ec2 associate-address --region=$${REGION} --instance-id=$${INSTANCE_ID} --public-ip=${elastic_ip}

# Try give things some time to settle down before trying to do other operations
sleep 20

# attach EBS devices
MAIN_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=${cluster_name}-master-${master_id}-main" --query "Volumes[0].VolumeId" --output text)
EVENTS_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=${cluster_name}-master-${master_id}-events" --query "Volumes[0].VolumeId" --output text)
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${MAIN_VOLUME_ID} --device=/dev/xvdg
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${EVENTS_VOLUME_ID} --device=/dev/xvdh

# Configuring Services
/opt/garbanzo/bin/bootstrap_route53.sh
/opt/garbanzo/bin/bootstrap_ssl.sh
/opt/garbanzo/bin/bootstrap_etcd.sh
/opt/garbanzo/bin/bootstrap_kubernetes.sh

# assume restricted running role
# FIXME BOOTSTRAP_PROFILE_ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations --region $${REGION} --filters Name=instance-id,Values=$${INSTANCE_ID} | jq -r .IamInstanceProfileAssociations[0].AssociationId)
# FIXME aws ec2 replace-iam-instance-profile-association --region $${REGION} --iam-instance-profile Arn=${running_profile_arn} --association-id $${BOOTSTRAP_PROFILE_ASSOCIATION_ID}
