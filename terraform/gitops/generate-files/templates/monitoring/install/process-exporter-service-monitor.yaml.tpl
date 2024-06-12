# NOTE: service monitor in helm char does not allow adding relabelings, therefore we have to maintain custom service-monitor
# https://github.com/mumoshu/prometheus-process-exporter/blob/master/charts/prometheus-process-exporter/templates/servicemonitor.yaml
# Request to fix in upstream: https://github.com/mumoshu/prometheus-process-exporter/issues/23
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