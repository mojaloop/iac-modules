apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: kubernetes
spec:
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-monitoring-dashboard
spec:
  folder: kubernetes
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/${grafana_dashboard_tag}/monitoring/dashboards/kubernetes/kubernetes-monitoring-dashboard.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-addons-trivy-operator
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 16337
    revision: 12
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-system-api-server
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15761
    revision: 16
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-system-coredns
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15762
    revision: 17
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-views-global
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15757
    revision: 36
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-views-namespaces
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15758
    revision: 32
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-views-nodes
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15759
    revision: 28
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: k8s-views-pods
spec:
  folder: kubernetes
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus"       
  grafanaCom:
    id: 15760
    revision: 26
---
