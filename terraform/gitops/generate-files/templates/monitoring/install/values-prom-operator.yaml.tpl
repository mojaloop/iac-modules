#values: https://github.com/prometheus-community/helm-charts/blob/kube-prometheus-stack-80.0.0/charts/kube-prometheus-stack/values.yaml

alertmanager:
  enabled: ${alertmanager_enabled}
  
  alertmanagerSpec:
    externalUrl: "https://${alertmanager_fqdn}"
    tolerations:
    - key: "workload-class.mojaloop.io/MONITORING"
      operator: "Equal"
      value: "enabled"
      effect: "NoSchedule"
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: ${storage_class_name}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    
    nodeSelector:
      workload-class.mojaloop.io/MONITORING: "enabled"
    
    alertmanagerConfigSelector:
      matchLabels:
        alertmanagerConfig: primary

    alertmanagerConfigMatcherStrategy:
      type: None

prometheus:
  enabled: true
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    probeSelectorNilUsesHelmValues: false

    scrapeInterval: ${prometheus_scrape_interval}
    evaluationInterval: ${prometheus_scrape_interval}
    retention: ${prometheus_retention_period}
    enableRemoteWriteReceiver: true

    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ${storage_class_name}
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: ${prometheus_pvc_size}
    tolerations:
    - key: "workload-class.mojaloop.io/MONITORING"
      operator: "Equal"
      value: "enabled"
      effect: "NoSchedule"
    
    nodeSelector:
      workload-class.mojaloop.io/MONITORING: "enabled"
    
    externalLabels:
      cluster: ${cluster_label}
    
    # TSDB Configuration
    disableCompaction: false
    additionalArgs:
      - name: storage.tsdb.min-block-duration
        value: ${prom_tsdb_min_block_duration}
      - name: storage.tsdb.max-block-duration
        value: ${prom_tsdb_max_block_duration}

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

prometheusOperator:
  enabled: true
  tolerations:
  - key: "workload-class.mojaloop.io/MONITORING"
    operator: "Equal"
    value: "enabled"
    effect: "NoSchedule"
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
  admissionWebhooks:
    patch:
      tolerations:
      - key: "workload-class.mojaloop.io/MONITORING"
        operator: "Equal"
        value: "enabled"
        effect: "NoSchedule"

kubelet:
  enabled: true
  serviceMonitor:
    interval: "${prometheus_scrape_interval}"
    metricRelabelings:
      # Drop high-cardinality metrics
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
    
    relabelings:
      - sourceLabels: [node]
        separator: ;
        regex: (.*)
        targetLabel: kubernetes_io_hostname
        replacement: $1
        action: replace
    
    cAdvisorMetricRelabelings:
      - sourceLabels: ['__name__']
        regex: 'container_tasks_state|container_memory_failures_total|container_blkio_device_usage_total'
        action: drop
      - regex: endpoint|service
        action: labeldrop
      # Remove hexadecimal name labels
      - sourceLabels: [name]
        regex: '^[a-f0-9]{64}$'
        targetLabel: name
        replacement: ''
        action: replace

kube-state-metrics:
  enabled: true
  tolerations:
  - key: "workload-class.mojaloop.io/MONITORING"
    operator: "Equal"
    value: "enabled"
    effect: "NoSchedule"
  prometheus:
    monitor:
      enabled: true
      
      metricRelabelings:
        - regex: uid
          action: labeldrop
      
      relabelings:
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

prometheus-node-exporter:
  enabled: true
  
  prometheus:
    monitor:
      enabled: true
      
      relabelings:
        - sourceLabels: [__meta_kubernetes_pod_node_name]
          targetLabel: nodename
        - regex: endpoint|service
          action: labeldrop
  
  tolerations:
  - key: "workload-class.mojaloop.io/MONITORING"
    operator: "Equal"
    value: "enabled"
    effect: "NoSchedule"

kubeApiServer:
  enabled: false 

commonLabels:
  build: argocd

grafana:
  enabled: false

kubeEtcd:
  enabled: false
