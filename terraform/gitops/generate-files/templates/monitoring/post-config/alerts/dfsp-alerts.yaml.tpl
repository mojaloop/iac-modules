apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: dfsp-alerts
  namespace: ${monitoring_namespace}
  labels: 
    release: prom
spec:
  groups:
  - name: dfsp.rules
    rules:
    - alert: DFSP_ConnectionError
      expr: mcm_api_dfsp_status_state > 0 
      for: 15m
      labels:
        severity: critical
      annotations:
        summary: "Mojaloop is facing connection errors with dfsp:{{ $labels.dfsp }}"
        description: "VALUE = {{ $value }}\n  LABELS = {{ $labels }}"