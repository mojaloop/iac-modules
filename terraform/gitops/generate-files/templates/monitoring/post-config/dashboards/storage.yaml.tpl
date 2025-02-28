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
  folder: monitoring
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/storage-quick-view.json"
---