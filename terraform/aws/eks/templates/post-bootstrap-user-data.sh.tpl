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
if [[ "${enable_registry_mirror}" == "true" && -n "${registry_mirror_fqdn}" ]]; then
    container_registry_mirrors="${container_registry_mirrors}"
    # Split the container_registry_mirrors into an array
    IFS=' ' read -r -a registry_array <<< "$${container_registry_mirrors}"

    # Loop through each registry and configure
    for registry in "$${registry_array[@]}"; do
        config_dir="/etc/containerd/certs.d/$${registry}/"
        config_file="$${config_dir}/hosts.toml"

        # Create the directory if it doesn't exist
        sudo mkdir -p "$config_dir"

        # Write the configuration to the file
        sudo tee "$config_file" > /dev/null <<EOF
server = "https://$${registry}"
[host."https://${registry_mirror_fqdn}"]
capabilities = ["pull", "resolve"]
EOF
    done

    # Restart containerd
    sudo systemctl restart containerd
fi