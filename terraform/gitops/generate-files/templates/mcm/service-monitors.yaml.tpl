apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mcm-servicemonitor
  annotations:
    app.kubernetes.io/description: "Enables monitoring of MCM applications (running without istio)"
spec:
  namespaceSelector:
    matchNames: [${mcm_namespace}]
  selector:
    matchExpressions:
    - key: app.kubernetes.io/name
      operator: In
      values:
      - connection-manager
  endpoints:
  - port: http
