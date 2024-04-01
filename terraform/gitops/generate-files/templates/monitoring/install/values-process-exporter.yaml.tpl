rbac:
  create: false
groups:
  - name: "{{.ExeFull}}"
    cmdline: 
    - '.+'  
serviceMonitor:
  enabled: true
  interval: "15s"    