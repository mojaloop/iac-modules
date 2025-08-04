apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: storage
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: storage-quick-view
spec:
  folder: storage
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/storage-quick-view.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: loki-storage
spec:
  folder: storage
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/loki-storage.json"
---