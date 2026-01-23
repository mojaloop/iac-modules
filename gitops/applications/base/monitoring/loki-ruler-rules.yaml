groups:
  # === 1. NUMBER OF LINES METRICS ===
  - name: log_lines_metrics
    interval: 5m
    rules:
      # Lines per namespace, app, pod, and container
      - record: loki_lines_total_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} [5m])
          )
  
  # === 2. NUMBER OF BYTES METRICS ===
  - name: log_bytes_metrics
    interval: 5m
    rules:
      # Bytes per namespace, app, pod, and container
      - record: loki_bytes_total_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            bytes_rate({pod=~".+"} [5m])
          )
  
  # === 3. ERROR LINES METRICS ===
  - name: log_error_metrics
    interval: 5m
    rules:
      # Error lines per namespace, app, pod, and container
      - record: loki_error_lines_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            rate({pod=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
