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
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: dashboard-quoting-service
spec:
  allowCrossNamespaceImport: true
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/ml-core-test-harness/v1.2.4-snapshot.0/docker/grafana/provisioning/dashboards/mojaloop/dashboard-quoting-service.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: dashboard-performance-troubleshooting
spec:
  allowCrossNamespaceImport: true
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/mojaloop/helm/4f23a2adb7b2f8ff58a7ce3f7665f3683f3b7e6b/monitoring/dashboards/mojaloop/dashboard-performance-troubleshooting.json"
---