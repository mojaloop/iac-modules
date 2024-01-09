
loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
  compactor: 
    retention_enabled: true
  limits_config:
    retention_period: 72h

singleBinary:
  replicas: 1
  persistence:
    enabled: true
    storageClassName: ${storage_class_name}
    size: 10Gi
monitoring:
  dashboards:
    enabled: false
  rules:
    enabled: false
  serviceMonitor:
    enabled: false
  selfMonitoring:
    enabled: false
test:
  enabled: false
