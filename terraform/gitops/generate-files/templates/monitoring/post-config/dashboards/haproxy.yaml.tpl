apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: HAProxy
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: haproxy-node-exporter-full
spec:
  folder: HAProxy
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/haproxy-node-exporter-full.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: haproxy-node-exporter-network
spec:
  folder: HAProxy
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/iac-modules/${grafana_dashboard_tag_iac_modules}/assets/grafana-dashboards/haproxy-node-exporter-network.json"
---
