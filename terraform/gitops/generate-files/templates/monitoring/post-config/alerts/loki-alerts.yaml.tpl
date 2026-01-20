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
          expr: loki_lines_total_by_namespace_app_pod_container > 100
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High log rate detected.  namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}, Container: {{ $labels.container }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (namespace {{ $labels.namespace }}, app {{ $labels.app }}) is sending more than 100 log lines per second."

        - alert: LokiPodHighErrorRate
          expr: |
            (
              sum by (namespace, app, pod) (loki_error_lines_by_namespace_app_pod_container)
              / 
              sum by (namespace, app, pod) (loki_lines_total_by_namespace_app_pod_container)
            ) > 0.05
          for: 10m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected.  namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} (app {{ $labels.app }}) has a high log error rate (>5%)."