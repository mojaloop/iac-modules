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
      - ml-api-adapter-handler-notification
      - centralledger-service
      - centralledger-handler-transfer-prepare
      - centralledger-handler-transfer-position
      - centralledger-handler-transfer-get
      - centralledger-handler-transfer-fulfil
      - centralledger-handler-timeout
      - centralledger-handler-admin-transfer
      - handler-pos-batch
      - quoting-service # NOTE: runs with istio but its metrics are not being exposed merged with istio proxy metrics
  endpoints:
  - port: http