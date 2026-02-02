groups:
  - name: loki_statistics
    interval: 5m
    rules:
      - record: loki_log_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} [5m])
          )
      - record: loki_log_bytes_rate
        expr: |
          sum by (namespace, app, pod, container) (
            bytes_rate({pod=~".+"} [5m])
          )
  - name: log_error_metrics
    interval: 5m
    rules:
      - record: loki_log_error_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
  - name: log_pattern_metrics
    interval: 5m
    rules:
      - record: loki_log_dns_timeout_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "EAI_AGAIN" [5m])
          )
      
      - record: loki_log_dns_not_found_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "getaddrinfo ENOTFOUND" [5m])
          )

      - record: loki_log_mysql_connection_lost_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "PROTOCOL_CONNECTION_LOST" [5m])
          )
%{ for pattern_name, pattern in log_alert_patterns ~}
      - record: loki_log_${replace(pattern_name, "-", "_")}_lines_rate
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "${pattern.regex}" [${pattern.interval}])
          )
%{ endfor ~}      
