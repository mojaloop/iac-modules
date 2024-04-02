apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: process-exporter-servicemonitor
  annotations:
    app.kubernetes.io/description: "Enables monitoring of prometheus-process-exporter"
spec:
  selector:
    matchLabels:
      app: prometheus-process-exporter
  endpoints:
  - port: metrics
    path: /metrics
    relabelings:
    - sourceLabels: [__meta_kubernetes_pod_node_name]
      targetLabel: nodename