#! /bin/bash

set -x
set -e
set -o pipefail

# Set hostname
echo "${hostname}" > /etc/hostname
hostname -F /etc/hostname

# gather running context
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -Ss http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# Attach elastic IP
aws ec2 associate-address --region=$${REGION} --instance-id=$${INSTANCE_ID} --public-ip=${elastic_ip}

# Try give things some time to settle down before trying to do other operations
sleep 20

# attach EBS devices
MAIN_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-${master_id}-main" --query "Volumes[0].VolumeId" --output text)
EVENTS_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-${master_id}-events" --query "Volumes[0].VolumeId" --output text)
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${MAIN_VOLUME_ID} --device=/dev/xvdg
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${EVENTS_VOLUME_ID} --device=/dev/xvdh

# assume restricted running role
BOOTSTRAP_PROFILE_ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations --region $${REGION} --filters Name=instance-id,Values=$${INSTANCE_ID} | jq -r .IamInstanceProfileAssociations[0].AssociationId)
aws ec2 replace-iam-instance-profile-association --region $${REGION} --iam-instance-profile Arn=${running_profile_arn} --association-id $${BOOTSTRAP_PROFILE_ASSOCIATION_ID}
