groups:
  # === 1. NUMBER OF LINES METRICS ===
  - name: log_lines_metrics
    interval: 5m
    rules:
      # Total lines per namespace
      - record: loki_lines_total_by_namespace
        expr: |
          sum by (namespace) (
            rate({namespace=~".+"} [5m])
          )
      
      # Lines per namespace and app
      - record: loki_lines_total_by_namespace_app
        expr: |
          sum by (namespace, app) (
            rate({namespace=~".+", app=~".+"} [5m])
          )
      
      # Lines per namespace, app, and pod
      - record: loki_lines_total_by_namespace_app_pod
        expr: |
          sum by (namespace, app, pod) (
            rate({namespace=~".+", app=~".+", pod=~".+"} [5m])
          )
      
      # Lines per namespace, app, pod, and container
      - record: loki_lines_total_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            rate({namespace=~".+", app=~".+", pod=~".+", container=~".+"} [5m])
          )
      
      # Lines per pod (simpler, commonly used)
      - record: loki_lines_total_by_pod
        expr: |
          sum by (namespace, pod) (
            rate({pod=~".+"} [5m])
          )
  
  # === 2. NUMBER OF BYTES METRICS ===
  - name: log_bytes_metrics
    interval: 5m
    rules:
      # Total bytes per namespace
      - record: loki_bytes_total_by_namespace
        expr: |
          sum by (namespace) (
            bytes_rate({namespace=~".+"} [5m])
          )
      
      # Bytes per namespace and app
      - record: loki_bytes_total_by_namespace_app
        expr: |
          sum by (namespace, app) (
            bytes_rate({namespace=~".+", app=~".+"} [5m])
          )
      
      # Bytes per namespace, app, and pod
      - record: loki_bytes_total_by_namespace_app_pod
        expr: |
          sum by (namespace, app, pod) (
            bytes_rate({namespace=~".+", app=~".+", pod=~".+"} [5m])
          )
      
      # Bytes per namespace, app, pod, and container
      - record: loki_bytes_total_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            bytes_rate({namespace=~".+", app=~".+", pod=~".+", container=~".+"} [5m])
          )
      
      # Bytes per pod (simpler, commonly used)
      - record: loki_bytes_total_by_pod
        expr: |
          sum by (namespace, pod) (
            bytes_rate({pod=~".+"} [5m])
          )
  
  # === 3. ERROR LINES METRICS ===
  - name: log_error_metrics
    interval: 5m
    rules:
      # Error lines per namespace
      - record: loki_error_lines_by_namespace
        expr: |
          sum by (namespace) (
            rate({namespace=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
      
      # Error lines per namespace and app
      - record: loki_error_lines_by_namespace_app
        expr: |
          sum by (namespace, app) (
            rate({namespace=~".+", app=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
      
      # Error lines per namespace, app, and pod
      - record: loki_error_lines_by_namespace_app_pod
        expr: |
          sum by (namespace, app, pod) (
            rate({namespace=~".+", app=~".+", pod=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
      
      # Error lines per namespace, app, pod, and container
      - record: loki_error_lines_by_namespace_app_pod_container
        expr: |
          sum by (namespace, app, pod, container) (
            rate({namespace=~".+", app=~".+", pod=~".+", container=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )
      
      # Error lines per pod (simpler)
      - record: loki_error_lines_by_pod
        expr: |
          sum by (namespace, pod) (
            rate({pod=~".+"} |~ "(?i)level.*(error|err)" [5m])
          )