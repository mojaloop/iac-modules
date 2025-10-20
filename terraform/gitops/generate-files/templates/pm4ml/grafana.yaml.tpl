apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: PM4ML
spec:
  allowCrossNamespaceImport: true
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mojaloop-connector
spec:
  allowCrossNamespaceImport: true
  folder: PM4ML
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/refs/heads/main/monitoring/dashboards/mojaloop/dashboard-mojaloop-connector.json"
