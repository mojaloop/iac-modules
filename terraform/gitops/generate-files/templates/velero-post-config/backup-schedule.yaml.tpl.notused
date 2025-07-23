apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ${velero_backup_schedule_name}
  namespace: ${velero_namespace}
spec:
  paused: false
  schedule: ${velero_backup_schedule}
  template:
    ttl: ${velero_backup_ttl}
    storageLocation: ${velero_backup_bucket_name}
    snapshotVolumes: false
    includedNamespaces:
      - '*'
    includedResources:
      - '*'
    hooks: {}
