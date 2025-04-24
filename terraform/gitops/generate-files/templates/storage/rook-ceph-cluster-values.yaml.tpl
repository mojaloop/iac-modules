%{ if cloud_provider == "bare-metal" ~}
---
operatorNamespace: ${storage_namespace}
cephClusterSpec:
  external:
    enable: true
  crashCollector:
    disable: true
  healthCheck:
    daemonHealth:
      mon:
        disabled: false
        interval: 45s

cephBlockPools: {}

cephFileSystems: {}

cephObjectStores: {}
%{ endif ~}