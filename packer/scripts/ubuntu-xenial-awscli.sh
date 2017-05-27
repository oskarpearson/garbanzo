#!/bin/bash

set -x
set -e
set -o pipefail

cd /tmp

curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

cd /
rm -rf /tmp/awscli-bundle
