apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mojaloop-servicemonitor
  annotations:
    app.kubernetes.io/description: "Enables monitoring of mojaloop applications (running without istio)"
spec:
  namespaceSelector: 
    matchNames: [${mojaloop_namespace}]
  selector:
    matchExpressions:
    - key: app.kubernetes.io/name
      operator: In
      values: 
      - ml-api-adapter-service
      - centralledger-service
      - quoting-service # NOTE: runs with istio but its metrics are not being exposed merged with istio proxy metrics
  endpoints:
  - port: http