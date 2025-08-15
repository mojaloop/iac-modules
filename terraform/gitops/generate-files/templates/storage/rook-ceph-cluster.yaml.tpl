apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: storage
  namespace: ${storage_namespace}
spec:
  external:
    enable: true
  crashCollector:
    disable: true
  healthCheck:
    daemonHealth:
      mon:
        disabled: false
        interval: 45s