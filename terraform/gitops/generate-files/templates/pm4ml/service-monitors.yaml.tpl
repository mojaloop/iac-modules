apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: pm4ml-servicemonitor
  annotations:
    app.kubernetes.io/description: "Enables monitoring of pm4ml applications"
spec:
  namespaceSelector:
    matchNames: [${pm4ml_namespace}]
  selector:
    matchExpressions:
    - key: app.kubernetes.io/name
      operator: In
      values:
      - sdk-scheme-adapter-api-svc
  endpoints:
  - port: metrics
