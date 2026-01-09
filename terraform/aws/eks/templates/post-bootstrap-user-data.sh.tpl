#!/bin/bash
# Registry Mirror Container proxy configurations
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
[host."https://${registry_mirror_fqdn}/v2/$${registry}"]
capabilities = ["pull", "resolve"]
override_path = true
EOF
    done
    # Restart containerd
    sudo systemctl restart containerd
fi