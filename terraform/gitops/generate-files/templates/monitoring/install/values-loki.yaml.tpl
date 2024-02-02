loki:
  overrideConfiguration:
    limits_config:
      retention_period: 72h
ingester:
  persistence:
    size: ${loki_ingester_pvc_size}
    storageClass: ${storage_class_name}
