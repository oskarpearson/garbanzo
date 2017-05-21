#!/bin/bash

# Thanks for some of this go to
# https://github.com/mafrosis/packer-templates/blob/master/script/cleanup.sh
# and https://github.com/mafrosis/packer-templates/blob/master/script/cleanup.sh

set -x
set -e
set -o pipefail

apt-get -y autoremove --purge
apt-get -y clean

rm -f \
  /root/.ssh/authorized_keys \
  /home/ubuntu/.ssh/authorized_keys \
  /etc/machine-id

touch /etc/machine-id

rm -f /var/lib/dhcp/*
find /var/log -type f | while read f; do echo -ne '' > $f; done;
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/ubuntu/.bash_history
