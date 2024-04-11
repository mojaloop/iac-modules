alertmanager:
  enabled: ${alertmanager_enabled}
  externalConfig: true
  configuration:
    name: alertmanager-config
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]       
prometheus:
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: ${prometheus_pvc_size}
  retention: ${prometheus_retention_period}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  # setting these to prevent oom issue https://github.com/prometheus/prometheus/issues/6934#issuecomment-1099293120
  disableCompaction: false #this is the default anyway
  additionalArgs:
  - name: storage.tsdb.min-block-duration
    value: ${prom_tsdb_min_block_duration}
  - name: storage.tsdb.max-block-duration
    value: ${prom_tsdb_max_block_duration}
operator:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]       
kubelet:
  serviceMonitor:
    relabelings:
    # adds kubernetes_io_hostname label being used by k8s monitoring dashboard
    - sourceLabels: [node]
      separator: ;
      regex: (.*)
      targetLabel: kubernetes_io_hostname
      replacement: $${1}
      action: replace

commonLabels:
  build: argocd
commonAnnotations:
  build: argocd

node-exporter:
  serviceMonitor:
    relabelings: 
    - sourceLabels: [__meta_kubernetes_pod_node_name]
      targetLabel: nodename
  tolerations:
    - operator: "Exists"
blackboxExporter:
  enabled: false    
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]     