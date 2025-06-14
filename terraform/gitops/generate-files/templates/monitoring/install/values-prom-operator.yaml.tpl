alertmanager:
  enabled: ${alertmanager_enabled}
  externalConfig: true
  configuration:
    name: alertmanager-config
  externalUrl: "https://${alertmanager_fqdn}"
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: 10Gi
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
prometheus:
  scrapeInterval: ${prometheus_scrape_interval}
  persistence:
    enabled: true
    storageClass: ${storage_class_name}
    size: ${prometheus_pvc_size}
  retention: ${prometheus_retention_period}
  enableRemoteWriteReceiver: true
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
    metadataConfig:
      sendInterval: ${prometheus_scrape_interval}
%{endif ~}


%{if enable_central_observability_read ~}
  remoteRead:
  - name: central-monitoring
    url: ${central_observability_endpoint}/prometheus/api/v1/read
    headers:
      X-Scope-OrgID: ${central_observability_tenant_id}
%{endif ~}


operator:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
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
      regex: 'etcd_request_duration_seconds_bucket|apiserver_watch_events_sizes_bucket'
      action: drop
    - regex: endpoint|service
      action: labeldrop
    cAdvisorMetricRelabelings:
    - sourceLabels: ['__name__']
      regex: 'container_tasks_state|container_memory_failures_total|container_blkio_device_usage_total'
      action: drop
    - regex: endpoint|service
      action: labeldrop
    # remove name label with hexadecimal values only
    - sourceLabels: [name]
      regex: '^[a-f0-9]{64}$'
      targetLabel: name
      replacement: ''
      action: replace
    # NOTE: removing this label is expected to reduce remote write bandwidth by 15%
    # removing id label causes err-mimir-sample-duplicate-timestamp error 
    # droping id entirely collapses multiple ts into one
    # - sourceLabels: [id]
    #   regex: '.+/pod.+'
    #  targetLabel: id
    #  replacement: ''
    #  action: replace

kubeApiServer:
  enabled: false

kube-state-metrics:
  serviceMonitor:
    relabelings:
    # NOTE: there are valid endpoint and service labels. Therefore, labeldrop can not be used.
    - sourceLabels: [endpoint]
      regex: http
      targetLabel: endpoint
      replacement: ''
      action: replace
    - sourceLabels: [service]
      regex: prom-kube-state-metrics
      targetLabel: service
      replacement: ''
      action: replace
    metricRelabelings:
    - regex: uid
      action: labeldrop

commonLabels:
  build: argocd
commonAnnotations:
  build: argocd

node-exporter:
  serviceMonitor:
    relabelings:
    - sourceLabels: [__meta_kubernetes_pod_node_name]
      targetLabel: nodename
    - regex: endpoint|service
      action: labeldrop
  tolerations:
    - operator: "Exists"
blackboxExporter:
  enabled: false
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]