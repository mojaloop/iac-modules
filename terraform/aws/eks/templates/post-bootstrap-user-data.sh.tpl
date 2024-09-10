#!/bin/bash
sudo tee /etc/yum.repos.d/netbird.repo <<EOF
[netbird]
name=netbird
baseurl=https://pkgs.netbird.io/yum/
enabled=1
gpgcheck=0
gpgkey=https://pkgs.netbird.io/yum/repodata/repomd.xml.key
repo_gpgcheck=1
EOF
yum install iscsi-initiator-utils -y && sudo systemctl enable iscsid && sudo systemctl start iscsid 
sudo yum install -y netbird-${netbird_version}
sudo netbird up -m ${netbird_api_host} -k ${netbird_setup_key}