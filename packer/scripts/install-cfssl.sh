#!/bin/bash

set -x
set -e
set -o pipefail

CFSSL_URL=https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
CFGSSLJSON_URL=https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

curl -sSL -o /usr/local/bin/cfssl ${CFSSL_URL}
curl -sSL -o /usr/local/bin/cfssljson ${CFGSSLJSON_URL}

chmod 755 /usr/local/bin/cfssl /usr/local/bin/cfssljson
chown root:root /usr/local/bin/cfssl /usr/local/bin/cfssljson
