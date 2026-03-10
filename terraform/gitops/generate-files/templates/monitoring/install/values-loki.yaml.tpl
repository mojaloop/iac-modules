# values: https://github.com/grafana/loki/blob/helm-loki-6.45.2/production/helm/loki/values.yaml

deploymentMode: Distributed

loki:
  auth_enabled: false
  extraArgs:
    - -config.expand-env=true
  # NEW SCHEMA - tsdb/v13 with different prefix from old boltdb-shipper
  schemaConfig:
    configs:
      - from: "2024-11-04"
        store: tsdb
        object_store: s3
        schema: v13
        index:
          prefix: tsdb_index_  # Different from old 'index_'
          period: 24h

  # SAME S3 BUCKET - but with proper path separation
  storage:
    type: s3
    bucketNames:
      chunks: ${loki_bucket}
      ruler: ${loki_bucket}
      admin: ${loki_bucket}
    s3:
      endpoint: ${object_store_regional_endpoint}
      region: ${object_store_region}
      accessKeyId: $${CEPH_LOKI_USERNAME}
      secretAccessKey: $${CEPH_LOKI_PASSWORD}
      s3ForcePathStyle: ${object_storage_path_style}
      insecure: ${object_store_insecure_connection}
      http_config:
        insecure_skip_verify: ${object_store_insecure_skip_verify}

  server:
    grpc_server_max_recv_msg_size: 8388608  # 8MB

  limits_config:
    retention_period: ${loki_ingester_retention_period}
    volume_enabled: true

  compactor:
    retention_enabled: true
    working_directory: /var/loki/compactor
    compaction_interval: 10m
    retention_delete_delay: 2h
    retention_delete_worker_count: 150
    delete_request_store: s3


  ingester:
    max_chunk_age: ${loki_ingester_max_chunk_age}
    chunk_encoding: snappy
    lifecycler:
      ring:
        replication_factor: ${loki_ingester_replication_factor}

  memberlistConfig:
    join_members:
      - "loki-memberlist:7946"


  commonConfig:
    replication_factor: ${loki_ingester_replication_factor}

  # TSDB Shipper config - this separates from boltdb-shipper paths
  storage_config:
    tsdb_shipper:
      active_index_directory: /var/loki/tsdb-index
      cache_location: /var/loki/tsdb-cache
    hedging:
      at: "250ms"
      max_per_second: 20
      up_to: 3

  rulerConfig:
    enable_api: true
    enable_alertmanager_v2: false  
    wal:
      dir: /var/loki/ruler-wal
    storage:
      type: local 
      local:
        directory: /etc/loki/rules
    rule_path: /tmp/rules
    ring:
      kvstore:
        store: memberlist 
    # How often to evaluate rules
    evaluation_interval: 5m
    # How often to poll for rule changes from storage
    poll_interval: 5m
    remote_write:
      enabled: true
      clients:
        prometheus:
          url: http://prometheus-operated:9090/api/v1/write

# Global extraEnvFrom for all components
global:
  dnsService: "external-dns" 
  dnsNamespace: "external-dns"
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}

# Ingester configuration
ingester:
  replicas: ${loki_ingester_replica_count}
  maxUnavailable: 1
  resources:
    requests:
      cpu: ${loki_ingester_requests_cpu}
      memory: ${loki_ingester_requests_memory}
    limits:
      cpu: ${loki_ingester_limits_cpu}
      memory: ${loki_ingester_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  persistence:
    enabled: true
    size: ${loki_ingester_pvc_size}
  zoneAwareReplication:
    enabled: false
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Distributor configuration
distributor:
  replicas: ${loki_distributor_replica_count}
  maxUnavailable: 1
  resources:
    requests:
      cpu: ${loki_distributor_requests_cpu}
      memory: ${loki_distributor_requests_memory}
    limits:
      cpu: ${loki_distributor_limits_cpu}
      memory: ${loki_distributor_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Querier configuration
querier:
  replicas: ${loki_querier_replica_count}
  maxUnavailable: 1
  resources:
    limits:
      cpu: ${loki_querier_limits_cpu}
      memory: ${loki_querier_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Query Frontend configuration
queryFrontend:
  replicas: 1
  resources:
    limits:
      cpu: ${loki_query_frontend_limits_cpu}
      memory: ${loki_query_frontend_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Query Scheduler configuration
queryScheduler:
  replicas: 1
  resources:
    limits:
      cpu: ${loki_query_scheduler_limits_cpu}
      memory: ${loki_query_scheduler_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}


# Compactor configuration
compactor:
  replicas: 1
  resources:
    limits:
      cpu: ${loki_compactor_limits_cpu}
      memory: ${loki_compactor_limits_memory}
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  persistence:
    enabled: true
    size: 10Gi
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Ruler configuration
ruler:
  enabled: true
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi
  persistence:
    enabled: true
    size: 10Gi
  extraVolumes:
    - name: rules-tmp
      emptyDir: {}
    - name: ruler-rules
      configMap:
        name: loki-ruler-rules
  extraVolumeMounts:
    - name: rules-tmp
      mountPath: /tmp/rules
    - name: ruler-rules
      mountPath: /etc/loki/rules/fake
      readOnly: true
  directories: {}

# Gateway configuration
gateway:
  enabled: true
  replicas: 1
  verboseLogging: true
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 200m
      memory: 256Mi
  service:
    type: ClusterIP
    port: 80
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Index Gateway (required for TSDB)
indexGateway:
  enabled: true
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  persistence:
    enabled: true
    size: 10Gi
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Chunks Cache (Memcached)
chunksCache:
  enabled: true
  replicas: 1
  allocatedMemory: 1400
  maxItemMemory: 5
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 2Gi
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Results Cache (Memcached)
resultsCache:
  enabled: true
  replicas: 1
  allocatedMemory: 1024
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 200m
      memory: 1Gi
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

# Monitoring
monitoring:
  serviceMonitor:
    enabled: true
    interval: ${prometheus_scrape_interval}
  rules:
    enabled: false
  dashboards:
    enabled: false

#Loki Canary
lokiCanary:
  enabled: true
  resources:
    requests:
      cpu: 25m
      memory: 32Mi
    limits:
      cpu: 100m
      memory: 128Mi
  nodeSelector:
    workload-class.mojaloop.io/MONITORING: "enabled"
%{if length(tolerations) > 0 ~}
  tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0
