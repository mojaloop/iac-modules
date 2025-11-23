
# ServiceMonitor configuration
serviceMonitor:
  enabled: true

lokiAddress: loki-grafana-loki-gateway:80


tolerations: |
  ${indent(4, yamlencode(tolerations))}