apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  labels:
    role: alert-rules
  name: k8s-health-rules
spec:
  groups:
  - name: k8s-component-health-rules
    rules:
    - alert: ExampleAlert
      expr: vector(2)        
  - name: k8s-capacity-alert-rules
    rules: []