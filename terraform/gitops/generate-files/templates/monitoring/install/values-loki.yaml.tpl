tableManager:
  enabled: true
  retention_deletes_enabled: true
  retention_period: 72h

loki:
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
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