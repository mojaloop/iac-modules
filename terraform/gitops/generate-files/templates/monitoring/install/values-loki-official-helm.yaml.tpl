# values: https://github.com/grafana/loki/blob/helm-loki-6.45.2/production/helm/loki/values.yaml

deploymentMode: Distributed

loki:
  auth_enabled: false
  extraArgs:
    - -config.expand-env=true
  # NEW SCHEMA - tsdb/v13 with different prefix from old boltdb-shipper
  schemaConfig:
    configs:
      - from: "2024-11-04"  # Use today's date for new schema start
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

# Global extraEnvFrom for all components
global:
  dnsService: "external-dns-app" 
  dnsNamespace: "external-dns"
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}

# Ingester configuration
ingester:
  replicas: ${loki_ingester_replica_count}
  maxUnavailable: 2
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  persistence:
    enabled: true
    size: 10Gi
  zoneAwareReplication:
    enabled: false
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Distributor configuration
distributor:
  replicas: ${loki_distributor_replica_count}
  maxUnavailable: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Querier configuration
querier:
  replicas: ${loki_querier_replica_count}
  maxUnavailable: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Query Frontend configuration
queryFrontend:
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Query Scheduler configuration
queryScheduler:
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]


# Compactor configuration
compactor:
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  persistence:
    enabled: true
    size: 10Gi
  extraArgs:
    - -config.expand-env=true
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]


# Ruler configuration
ruler:
  enabled: true
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  extraArgs:
    - -config.expand-env=true

# Gateway configuration
gateway:
  enabled: true
  replicas: 1
  verboseLogging: true
  service:
    type: ClusterIP
    port: 80
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Index Gateway (required for TSDB)
indexGateway:
  enabled: true
  replicas: 1
  extraEnvFrom:
    - secretRef:
        name: ${object_store_loki_credentials_secret_name}
  persistence:
    enabled: true
    size: 10Gi
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

# Chunks Cache (Memcached)
chunksCache:
  enabled: true
  replicas: 1
  allocatedMemory: 1400
  maxItemMemory: 5

# Results Cache (Memcached)
resultsCache:
  enabled: true
  replicas: 1
  allocatedMemory: 1024

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

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0