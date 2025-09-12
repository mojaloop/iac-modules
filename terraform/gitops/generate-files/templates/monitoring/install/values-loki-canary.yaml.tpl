
# ServiceMonitor configuration
serviceMonitor:
  # -- If enabled, ServiceMonitor resources for Prometheus Operator are created
  enabled: true
  # -- Alternative namespace for ServiceMonitor resources
  namespace: ${monitoring_namespace}
  # -- Namespace selector for ServiceMonitor resources
  namespaceSelector: {}
  # -- ServiceMonitor annotations
  annotations: {}
  # -- Additional ServiceMonitor labels
  labels: {}
  # -- ServiceMonitor scrape interval
  interval: 30s
  # -- ServiceMonitor scrape timeout in Go duration format (e.g. 15s)
  scrapeTimeout: null

# -- The Loki server URL:Port, e.g. loki:3100
lokiAddress: loki-grafana-loki-gateway:80


