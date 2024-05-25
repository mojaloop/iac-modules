apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaFolder
metadata:
  name: kafka
spec:
  allowCrossNamespaceImport: true
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
---
apiVersion: grafana.integreatly.org/v1beta1
kind: GrafanaDashboard
metadata:
  name: strimzi-kafka
spec:
  allowCrossNamespaceImport: true
  folder: mojaloop
  instanceSelector:
    matchLabels:
      dashboards: "grafana"
  datasources:
    - inputName: "DS_PROMETHEUS"
      datasourceName: "Prometheus" 
  url: "https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/0.41.0/examples/metrics/grafana-dashboards/strimzi-kafka.json"
---