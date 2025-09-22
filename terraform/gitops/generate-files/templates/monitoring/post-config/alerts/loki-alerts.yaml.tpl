apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: loki-canary-alerts
  namespace: ${monitoring_namespace}
spec:
  groups:
  - name: loki-canary.rules
    rules:
    - alert: LokiCanaryMissingEntriesHigh
      expr: rate(loki_canary_missing_entries_total[${prometheus_rate_interval}]) >= 0.5
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "Loki Canary is missing too many entries"
        description: "The rate of missing entries has been above 0.5 for 10 minutes."