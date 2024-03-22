loki:
  overrideConfiguration:
    limits_config:
      retention_period: ${loki_ingester_retention_period}
ingester:
  persistence:
    size: ${loki_ingester_pvc_size}
    storageClass: ${storage_class_name}
promtail:
  tolerations:  
    - operator: "Exists"