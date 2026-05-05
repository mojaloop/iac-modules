apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_name}
  kubelet:
    config:
      clusterDNS:
        - ${coredns_bind_address}
      allowedUnsafeSysctls:
        - net.ipv4.ip_forward
      maxPods: ${max_pods}
    flags:
%{ if node_labels != "" ~}
      - --node-labels=${node_labels}
%{ endif ~}
%{ if node_taints != "" ~}
      - --register-with-taints=${node_taints}
%{ endif ~}
%{ if configure_containerd_hosts ~}
  containerd:
    config: |
      [plugins."io.containerd.cri.v1.images".registry]
        config_path = "/etc/containerd/certs.d"
%{ endif ~}