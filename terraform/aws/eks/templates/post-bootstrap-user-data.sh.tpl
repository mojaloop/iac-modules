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

# Netbird install and configure
if [[ -n "${netbird_version}" && -n "${netbird_api_host}" && -n "${netbird_setup_key}" ]]; then
    sudo yum install -y netbird-"${netbird_version}"
    sudo netbird up -m "${netbird_api_host}" -k "${netbird_setup_key}"
    sudo iptables -t nat -I POSTROUTING -s ${pod_network_cidr} -o wt0 -j MASQUERADE
fi

# Nexus Container registry proxy configurations
container_registry_mirrors="{{container_registry_mirrors}}"
enable_registry_mirror={{enable_registry_mirror}}
if [[ "${enable_registry_mirror,,}" == "true" && -n "${registry_mirror_fqdn}" ]]; then
    for registry in ${container_registry_mirrors}; do
        config_dir="/etc/containerd/certs.d/${registry}/"
        config_file="${config_dir}/hosts.toml"

        sudo mkdir -p "$config_dir"
        sudo tee "$config_file" <<EOF
server = "https://${registry}"
[host."https://${registry_mirror_fqdn}"]
capabilities = ["pull", "resolve"]
EOF
    done
    sudo systemctl restart containerd    
fi