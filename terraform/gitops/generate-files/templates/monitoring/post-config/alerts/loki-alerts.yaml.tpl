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
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "Loki Canary is missing too many entries"
            description: "The rate of missing entries has been above 0.5 for 10 minutes."

    - name: loki-logging.rules
      rules:
        - alert: LokiContainerHighLogRate
          expr: loki_log_lines_rate > 100
          for: 15m
          labels:
            severity: warning
          annotations:
            summary: "High log rate detected. cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}, Container: {{ $labels.container }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }}, app {{ $labels.app }}) is sending more than 100 log lines per second."

        - alert: LokiPodHighErrorRate
          expr: |
            (
              sum by (cluster, namespace, app, pod) (loki_log_error_lines_rate)
              / 
              sum by (cluster, namespace, app, pod) (loki_log_lines_rate)
            ) > 0.05
          for: 15m
          labels:
            severity: critical
          annotations:
            summary: "High error rate detected. cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Pod {{ $labels.pod }} in cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }} (app {{ $labels.app }}) has a high log error rate (>5%)."
        
        - alert: LokiDnsTimeoutDetected
          expr: loki_log_dns_timeout_lines_rate > 1
          for: 15m
          labels:
            severity: warning
            pattern: dns-timeout
          annotations:
            summary: "DNS timeout detected - cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }}, app {{ $labels.app }}) is experiencing DNS timeout issues (rate: {{ $value }} logs/sec)."
        
        - alert: LokiDnsNotFoundDetected
          expr: loki_log_dns_not_found_lines_rate > 1
          for: 15m
          labels:
            severity: warning
            pattern: dns-not-found
          annotations:
            summary: "DNS not found detected - cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }}, app {{ $labels.app }}) is experiencing DNS resolution failures (rate: {{ $value }} logs/sec)."
        
        - alert: LokiMysqlConnectionLostDetected
          expr: loki_log_mysql_connection_lost_lines_rate > 0.5
          for: 15m
          labels:
            severity: critical
            pattern: mysql-connection-lost
          annotations:
            summary: "MySQL connection lost - cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }}, app {{ $labels.app }}) is experiencing MySQL connection issues (rate: {{ $value }} logs/sec)."
%{ for pattern_name, pattern in log_alert_patterns ~}
        
        - alert: Loki${replace(title(replace(pattern_name, "-", " ")), " ", "")}Detected
          expr: loki_log_${replace(pattern_name, "-", "_")}_lines_rate > ${pattern.threshold}
          for: 15m
          labels:
            severity: ${pattern.severity}
            pattern: ${pattern_name}
          annotations:
            summary: "${pattern.description} - cluster: {{ $labels.cluster }}, namespace: {{ $labels.namespace }}, app: {{ $labels.app }}, pod: {{ $labels.pod }}"
            description: "Container {{ $labels.container }} in pod {{ $labels.pod }} (cluster {{ $labels.cluster }}, namespace {{ $labels.namespace }}, app {{ $labels.app }}) is experiencing ${pattern_name} issues (rate: {{ $value }} logs/sec)."
%{ endfor ~}
