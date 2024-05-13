loki:
  overrideConfiguration:
    # https://grafana.com/docs/loki/latest/operations/storage/retention/
    compactor:
      retention_enabled: true # enable deletion using compactor
      shared_store: s3
    limits_config:
      retention_period: ${loki_ingester_retention_period}
    ingester: 
      max_chunk_age: 15m # TODO: make it configurable 
    schema_config:
      configs:
      - from: 2020-10-24
        store: boltdb-shipper
        object_store: s3
        schema: v11
        index:
          prefix: index_
          period: 24h            
    storage_config:
      boltdb_shipper:
        shared_store: s3
      aws:
        # s3 is alias for aws 
        s3forcepathstyle: true
        endpoint: ${minio_api_url}
        insecure: true
        access_key_id: $${MINIO_LOKI_USERNAME}
        secret_access_key: $${MINIO_LOKI_PASSWORD}
        bucketnames: ${minio_loki_bucket}      

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    relabelings:
    - source_labels: []
      action: replace
      target_label: job
      replacement: ${monitoring_namespace}/loki-write



# NOTE: make sure all components which are running have node affinity enabled for monitoring nodes
ingester:
  persistence:
    size: ${loki_ingester_pvc_size}
    storageClass: ${storage_class_name}
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"] 
compactor:
  # https://grafana.com/docs/loki/latest/operations/storage/boltdb-shipper/#compactor
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]  
distributor:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
gateway:      
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
querier:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
queryFrontend:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
queryScheduler:
  enabled: true
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_loki_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]

memcachedchunks:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
  resourcesPreset: medium # https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_resources.tpl
  command:
    - "/opt/bitnami/scripts/memcached/entrypoint.sh"
    - "/opt/bitnami/scripts/memcached/run.sh"
  args:
    # medium profile memory-limit: 1536Mi. Setting value slightly below that.
    # See https://github.com/memcached/memcached/wiki/ConfiguringServer#commandline-arguments
    # We only updated memory-limit and max-item-size
    # We did not add extended params related to external store because as of now, we keep all our cache in memory.
    # We did not change "aggressive" configs for memcache client in loki since memcache is completely RAM backed as of now.
    - "--memory-limit=1400"   # max memory limit for all cached items in mega bytes
    - "--max-item-size=2m"    # max memory limit for a single item
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
memcachedfrontend:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
memcachedindexqueries:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]    
memcachedindexwrites:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]    



promtail:
  # reference: https://github.com/bitnami/charts/blob/5f843aec99a13573f67e59b5e3193916ca01f308/bitnami/grafana-loki/values.yaml#L4440
  # only multiline stage has been added in pipeline_stages
  configuration: |
    server:
      log_level: {{ .Values.promtail.logLevel }}
      http_listen_port: {{ .Values.promtail.containerPorts.http }}

    clients:
      - url: http://{{ include "grafana-loki.gateway.fullname" . }}:{{ .Values.gateway.service.ports.http }}/loki/api/v1/push
        {{- if .Values.gateway.auth.enabled }}
        basic_auth:
          # The username to use for basic auth
          username: {{ .Values.gateway.auth.username }}
          password_file: /bitnami/promtail/conf/secrets/password
        {{- end }}
    positions:
      filename: /run/promtail/positions.yaml

    scrape_configs:
      # See also https://github.com/grafana/loki/blob/master/production/ksonnet/promtail/scrape_config.libsonnet for reference
      - job_name: kubernetes-pods
        pipeline_stages:
          - cri: {}
          - multiline:
              firstline: '^\d{4}-\d{2}-\d{2}T\d{1,2}:\d{2}:\d{2}\.\d{3}'
              max_wait_time: 3s
              max_lines: 128
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels:
              - __meta_kubernetes_pod_controller_name
            regex: ([0-9a-z-.]+?)(-[0-9a-f]{8,10})?
            action: replace
            target_label: __tmp_controller_name
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
              - __meta_kubernetes_pod_label_app
              - __tmp_controller_name
              - __meta_kubernetes_pod_name
            regex: ^;*([^;]+)(;.*)?$
            action: replace
            target_label: app
          - source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_component
              - __meta_kubernetes_pod_label_component
            regex: ^;*([^;]+)(;.*)?$
            action: replace
            target_label: component
          - action: replace
            source_labels:
            - __meta_kubernetes_pod_node_name
            target_label: node_name
          - action: replace
            source_labels:
            - __meta_kubernetes_namespace
            target_label: namespace
          - action: replace
            replacement: $1
            separator: /
            source_labels:
            - namespace
            - app
            target_label: job
          - action: replace
            source_labels:
            - __meta_kubernetes_pod_name
            target_label: pod
          - action: replace
            source_labels:
            - __meta_kubernetes_pod_container_name
            target_label: container
          - action: replace
            replacement: /var/log/pods/*$1/*.log
            separator: /
            source_labels:
            - __meta_kubernetes_pod_uid
            - __meta_kubernetes_pod_container_name
            target_label: __path__
          - action: replace
            regex: true/(.*)
            replacement: /var/log/pods/*$1/*.log
            separator: /
            source_labels:
            - __meta_kubernetes_pod_annotationpresent_kubernetes_io_config_hash
            - __meta_kubernetes_pod_annotation_kubernetes_io_config_hash
            - __meta_kubernetes_pod_container_name
            target_label: __path__
  tolerations:  
    - operator: "Exists"