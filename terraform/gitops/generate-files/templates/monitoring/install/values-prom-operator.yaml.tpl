alertmanager:
  enabled: ${alertmanager_enabled}
  externalConfig: true
  configuration:
    name: alertmanager-config
  externalUrl: ${alertmanager_fqdn}
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
  externalLabels:
    cluster: ${cluster_label}

%{if enable_central_observability_write ~}
  remoteWrite:
  - name: central-monitoring
    url: ${central_observability_endpoint}/api/v1/push
    headers:
      X-Scope-OrgID: ${central_observability_tenant_id} 
%{endif ~} 

%{if enable_central_observability_read ~}
  remoteRead:
  - name: central-monitoring
    url: ${central_observability_endpoint}/api/v1/read
    headers:
      X-Scope-OrgID: ${central_observability_tenant_id}    
%{endif ~} 


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
    metricRelabelings:      
    - sourceLabels: ['__name__']
      regex: 'apiserver_request_duration_seconds_bucket|apiserver_request_sli_duration_seconds_bucket'
      action: drop
    - sourceLabels: ['__name__']
      regex: 'apiserver_request_body_size_bytes_bucket|apiserver_response_sizes_bucket'
      action: drop      
    - sourceLabels: ['__name__']
      regex: 'etcd_request_duration_seconds_bucket'
      action: drop

kubeApiServer:
  enabled: false	

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