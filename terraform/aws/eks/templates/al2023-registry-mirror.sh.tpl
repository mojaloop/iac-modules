#!/bin/bash
set -euo pipefail

mkdir -p /etc/containerd/certs.d

%{ for registry in container_registry_mirrors ~}
mkdir -p /etc/containerd/certs.d/${registry}
cat >/etc/containerd/certs.d/${registry}/hosts.toml <<'EOF'
server = "https://${registry}"

[host."https://${registry_mirror_fqdn}/v2/${registry}"]
  capabilities = ["pull", "resolve"]
  override_path = true
%{ if registry_mirror_basic_auth != "" ~}
  [host."https://${registry_mirror_fqdn}/v2/${registry}".header]
    authorization = ["Basic ${registry_mirror_basic_auth}"]
%{ endif ~}
EOF

%{ endfor ~}
