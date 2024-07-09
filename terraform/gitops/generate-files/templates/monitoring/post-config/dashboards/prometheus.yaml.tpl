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
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: prometheus-overview
spec:
  folder: kubernetes
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/monitoring-mixins/website/master/assets/prometheus/dashboards/prometheus.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mojaloop-prometheus-remote-write
spec:
  folder: kubernetes
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/infrastructure/prometheus-remote-write.json"
---