# WARNING: This service monitoring is added to make loki-chunks dashboard happy with job label. 
# In the long run, we should fix the loki-chunk dashboard job label using mixins 

apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: loki-ingester-custom-servicemonitor-temporary
  annotations:
    app.kubernetes.io/description: "Allows scraping loki metrics with custom job label to support hardcoded job value in dashboards."
spec:
  namespaceSelector: 
    matchNames: [${monitoring_namespace}]
  selector:
    matchLabels:
      app.kubernetes.io/part-of: grafana-loki
      app.kubernetes.io/component: ingester
  endpoints:
  - port: http
    relabelings:
    - sourceLabels: []
      action: replace
      targetLabel: job
      replacement: ${monitoring_namespace}/loki-write
