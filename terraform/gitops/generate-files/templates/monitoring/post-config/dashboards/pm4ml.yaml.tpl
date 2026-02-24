apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: pm4ml
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mojaloop-connector
spec:
  folder: pm4ml
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/mojaloop-connector.json"
---
