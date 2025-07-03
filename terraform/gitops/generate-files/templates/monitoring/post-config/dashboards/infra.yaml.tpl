apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: infra
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: "networking-cost-estimation"
spec:
  folder: infra
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/networking-cost-estimation.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: "kubernetes-capacity-planning"
spec:
  folder: infra
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/kubernetes-capacity-planning.json"
---