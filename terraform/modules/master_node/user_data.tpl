#! /bin/bash

set -x
set -e
set -o pipefail

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
apt-get -y install jq python unzip

# install aws cli
cd /tmp
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# gather running context
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -Ss http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# attach EBS devices
MAIN_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-1-main" --query "Volumes[0].VolumeId" --output text)
EVENTS_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-1-events" --query "Volumes[0].VolumeId" --output text)
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${MAIN_VOLUME_ID} --device=/dev/xvdg
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${EVENTS_VOLUME_ID} --device=/dev/xvdh

# attach elastic IP
aws ec2 associate-address --region=$${REGION} --instance-id=$${INSTANCE_ID} --public-ip=${elastic_ip}

# assume restricted running role
BOOTSTRAP_PROFILE_ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations --region $${REGION} --filters Name=instance-id,Values=$${INSTANCE_ID} | jq -r .IamInstanceProfileAssociations[0].AssociationId)
aws ec2 replace-iam-instance-profile-association --region $${REGION} --iam-instance-profile Arn=${running_profile_arn} --association-id $${BOOTSTRAP_PROFILE_ASSOCIATION_ID}
