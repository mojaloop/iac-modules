apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: kubernetes
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-monitoring-dashboard
spec:
  folder: kubernetes
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/v15.4.0-snapshot.1/monitoring/dashboards/kubernetes/kubernetes-monitoring-dashboard.json"
---
