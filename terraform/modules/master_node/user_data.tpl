#! /bin/bash

set -x
set -e
set -o pipefail

apt-get update
apt-get -y upgrade
apt-get -y install jq python unzip

cd /tmp

curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip

unzip awscli-bundle.zip

./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -Ss http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
MAIN_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-1-main" --query "Volumes[0].VolumeId" --output text)
EVENTS_VOLUME_ID=$(aws ec2 describe-volumes --region=$${REGION} --filters "Name=tag:Name,Values=kuberhacking-master-1-events" --query "Volumes[0].VolumeId" --output text)

aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${MAIN_VOLUME_ID} --device=/dev/xvdg
aws ec2 attach-volume --region=$${REGION} --instance-id=$${INSTANCE_ID} --volume-id=$${EVENTS_VOLUME_ID} --device=/dev/xvdh

echo "aws ec2 attach-ip {{ elastic_ip }}"
