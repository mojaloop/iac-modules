apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: loki-alerts
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

    - name: loki-logging.rules
      rules:
        - alert: LokiContainerHighLogRate
          expr: rate(loki_lines_total_by_namespace_app_pod_container{namespace="${namespace}", app="${app}", pod="${pod}", container="${container}"}[1m]) > 100
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High log rate detected from container"
            description: "Container ${container} in pod ${pod} is sending more than 100 log lines per second over the last 5 minutes."

        - alert: LokiPodHighErrorRate
          expr: rate(loki_error_lines_by_pod{namespace="${namespace}", pod="${pod}"}[1h]) / ignoring(container) rate(loki_lines_total_by_namespace_app_pod_container{namespace="${namespace}", pod="${pod}"}[1h]) > 0.05
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "High error rate in pod"
            description: "Pod ${pod} in namespace ${namespace} has a high log error rate (>5%) over the last hour."