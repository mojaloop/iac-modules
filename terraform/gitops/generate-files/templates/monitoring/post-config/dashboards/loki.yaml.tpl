apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: loki-chunks
spec:
  folder: monitoring
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/grafana/loki/v3.0.0/production/helm/loki/src/dashboards/loki-chunks.json"
---