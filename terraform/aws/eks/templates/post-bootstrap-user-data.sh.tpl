#!/bin/bash

yum install iscsi-initiator-utils -y && sudo systemctl enable iscsid && sudo systemctl start iscsid 
sudo yum install -y netbird=${netbird_version}
sudo netbird up -m ${netbird_api_host} -k ${netbird_setup_key}