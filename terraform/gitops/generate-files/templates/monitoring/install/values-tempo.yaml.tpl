tempo:
  # source: https://github.com/bitnami/charts/blob/a3c7c6e5bc685b2587a6302770e20c6890ebd72d/bitnami/grafana-tempo/values.yaml#L136C3-L231C48
  configuration: |
    multitenancy_enabled: false
    cache:
      caches:
        - memcached:
            host: {{ include "grafana-tempo.memcached.url" . }}
            service: memcache
            timeout: 500ms
            consistent_hash: true
          roles:
            - bloom
            - trace-id-index
    compactor:
      compaction:
        block_retention: ${tempo_retention_period}
      ring:
        kvstore:
          store: memberlist
    distributor:
      ring:
        kvstore:
          store: memberlist
      receivers:
        {{- if  or (.Values.tempo.traces.jaeger.thriftCompact) (.Values.tempo.traces.jaeger.thriftBinary) (.Values.tempo.traces.jaeger.thriftHttp) (.Values.tempo.traces.jaeger.grpc) }}
        jaeger:
          protocols:
            {{- if .Values.tempo.traces.jaeger.thriftCompact }}
            thrift_compact:
              endpoint: 0.0.0.0:6831
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.thriftBinary }}
            thrift_binary:
              endpoint: 0.0.0.0:6832
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.thriftHttp }}
            thrift_http:
              endpoint: 0.0.0.0:14268
            {{- end }}
            {{- if .Values.tempo.traces.jaeger.grpc }}
            grpc:
              endpoint: 0.0.0.0:14250
            {{- end }}
        {{- end }}
        {{- if .Values.tempo.traces.zipkin }}
        zipkin:
          endpoint: 0.0.0.0:9411
        {{- end }}
        {{- if or (.Values.tempo.traces.otlp.http) (.Values.tempo.traces.otlp.grpc) }}
        otlp:
          protocols:
            {{- if .Values.tempo.traces.otlp.http }}
            http:
              endpoint: 0.0.0.0:55681
            {{- end }}
            {{- if .Values.tempo.traces.otlp.grpc }}
            grpc:
              endpoint: 0.0.0.0:4317
            {{- end }}
        {{- end }}
        {{- if .Values.tempo.traces.opencensus }}
        opencensus:
          endpoint: 0.0.0.0:55678
        {{- end }}
    querier:
      frontend_worker:
        frontend_address: {{ include "grafana-tempo.query-frontend.fullname" . }}-headless:{{ .Values.queryFrontend.service.ports.grpc }}
    ingester:
      lifecycler:
        ring:
          replication_factor: 1
          kvstore:
            store: memberlist
        tokens_file_path: {{ .Values.tempo.dataDir }}/tokens.json
    metrics_generator:
      ring:
        kvstore:
          store: memberlist
      storage:
        path: {{ .Values.tempo.dataDir }}/wal
        remote_write: {{ include "common.tplvalues.render" (dict "value" .Values.metricsGenerator.remoteWrite "context" $) | nindent 6 }}
    memberlist:
      abort_if_cluster_join_fails: false
      join_members:
        - {{ include "grafana-tempo.gossip-ring.fullname" . }}
    overrides:
      per_tenant_override_config: /bitnami/grafana-tempo/conf/overrides.yaml
    server:
      http_listen_port: {{ .Values.tempo.containerPorts.web }}
    storage:
      trace:
        backend: s3
        blocklist_poll: 5m
        local:
          path: {{ .Values.tempo.dataDir }}/traces
        wal:
          path: {{ .Values.tempo.dataDir }}/wal
        s3:
          forcepathstyle: true
          endpoint: ${minio_api_url}
          insecure: true
          bucket: ${minio_tempo_bucket}   


compactor:
  resourcesPreset: large
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]  
distributor:
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
ingester:
  resourcesPreset: large
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
metricsGenerator:
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
querier:
  resourcesPreset: small
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
queryFrontend:
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
vulture:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
memcached:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
