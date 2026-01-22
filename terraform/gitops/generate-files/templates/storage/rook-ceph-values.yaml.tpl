%{ if cloud_provider == "private-cloud" ~}
tolerations:
  - key: "netbird/ready"
    operator: "Exists"
    effect: "NoExecute"
csi:
  pluginTolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  provisionerTolerations:
    - key: "netbird/ready"
      operator: "Exists"
      effect: "NoExecute"
  kubeletDirPath: "${kubelet_dir_path}"
  serviceMonitor:
    enabled: false
    interval: 60s
  enableCSIHostNetwork: false
  enableDiscoveryDaemon: false
monitoring:
  enabled: false # true
  # externalMgrEndpoints:
  #   - ip: "192.168.0.2"
  #   - ip: "192.168.0.3"
resources:
  limits:
    memory: 512Mi
  requests:
    cpu: 50m
    memory: 64Mi
%{ endif ~}