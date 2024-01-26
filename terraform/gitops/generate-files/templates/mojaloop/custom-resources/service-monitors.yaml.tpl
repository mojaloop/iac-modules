apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mojaloop-servicemonitor
  annotations:
    app.kubernetes.io/description: "Enables monitoring of mojaloop applications"
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
      - quoting-service
  endpoints:
  - port: http