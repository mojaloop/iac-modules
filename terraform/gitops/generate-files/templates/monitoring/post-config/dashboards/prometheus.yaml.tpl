apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-addons-prometheus
spec:
  folder: monitoring
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 19105
    revision: 3
---