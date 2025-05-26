%{ if cloud_provider == "private-cloud" ~}
csi:
 kubeletDirPath: "${kubelet_dir_path}"
 serviceMonitor:
  enabled: false
  interval: 60s
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