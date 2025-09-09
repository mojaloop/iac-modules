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
    containerd_config_file="/etc/containerd/config.toml"
    if [[ -f "$containerd_config_file" ]]; then
        # Backup the original config
        sudo cp "$containerd_config_file" "$containerd_config_file.backup"
        
        # Add custom configuration to containerd.toml
        # Example: Adding registry configuration or other settings
        sudo tee -a "$containerd_config_file" > /dev/null <<EOF

# Custom configuration added by post-bootstrap script
[plugins."io.containerd.grpc.v1.cri".registry.configs]
  [plugins."io.containerd.grpc.v1.cri".registry.configs."${registry_mirror_fqdn}".auth]
    username = "${docker_registry_username}"
    password = "${docker_registry_password}"
EOF
    fi
    # Restart containerd
    sudo systemctl restart containerd
fi