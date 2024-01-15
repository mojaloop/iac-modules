apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: mojaloop
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: node-js
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-NodeJSApplication.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: account-lookup-service
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-account-lookup-service.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: central-services-characterization
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-central-services-characterization.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: central-services
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-central-services.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: dashboard-ml-adapter
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-ml-adapter.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: dashboard-simulators
spec:
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-simulators.json"
---