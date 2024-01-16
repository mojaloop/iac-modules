apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: mojaloop
spec:
  allowCrossNamespaceImport: true
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: node-js
spec:
  allowCrossNamespaceImport: true
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
  allowCrossNamespaceImport: true
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
  allowCrossNamespaceImport: true
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
  allowCrossNamespaceImport: true
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
  allowCrossNamespaceImport: true
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
  allowCrossNamespaceImport: true
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/v${grafana_dashboard_tag}/monitoring/dashboards/mojaloop/dashboard-simulators.json"
---