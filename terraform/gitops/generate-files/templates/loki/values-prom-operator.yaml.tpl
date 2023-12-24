alertmanager:
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi
prometheus:
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi