apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: mysql-exporter-quickstart
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/${grafana_dashboard_tag}/monitoring/dashboards/datastore/dashboard-mysql-exporter-quickstart.json"
---
# NOTE: There is some problem with the dashboard. It is not being added to grafana and operator is in retry loop. 
# Does not show logs either
# apiVersion: grafana.integreatly.org/v1beta1
# kind: GrafanaDashboard
# metadata:
#   name: mongodb
# spec:
#   folder: default
#   instanceSelector:
#     matchLabels:
#       dashboards: "grafana"
#   grafanaCom:
#     id: 2583
#     revision: 2
# ---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: redis
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/${grafana_dashboard_tag}/monitoring/dashboards/datastore/dashboard-redis-exporter-quickstart.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: kafka-topic-overview
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/${grafana_dashboard_tag}/monitoring/dashboards/messaging/dashboard-kafka-topic-overview.json"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: kafka-cluster-overview
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  url: "https://raw.githubusercontent.com/mojaloop/helm/${grafana_dashboard_tag}/monitoring/dashboards/messaging/dashboard-kafka-cluster-overview.json"
---

apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: process-exporter
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 249
    revision: 2

---

apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: memcached-exporter
spec:
  folder: default
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  grafanaCom:
    id: 11527
    revision: 1