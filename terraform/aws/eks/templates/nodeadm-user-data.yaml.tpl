---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  kubelet:
    config:
      clusterDNS:
        - ${cluster_dns}
      allowedUnsafeSysctls:
        - net.ipv4.ip_forward
      maxPods: 122
%{ if node_labels != "" || node_taints != "" ~}
    flags:
%{ if node_labels != "" ~}
      - --node-labels=${node_labels}
%{ endif ~}
%{ if node_taints != "" ~}
      - --register-with-taints=${node_taints}
%{ endif ~}
%{ endif ~}
%{ if configure_containerd_hosts ~}
  containerd:
    config: |
      [plugins."io.containerd.cri.v1.images".registry]
        config_path = "/etc/containerd/certs.d"
%{ endif ~}
