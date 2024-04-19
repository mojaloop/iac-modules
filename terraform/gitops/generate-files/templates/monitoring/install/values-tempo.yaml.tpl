compactor:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]  
distributor:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
ingester:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
metricsGenerator:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
querier:
  extraArgs: ["-config.expand-env"]
  extraEnvVarsSecret: ${minio_tempo_credentials_secret_name}
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]   
queryFrontend:
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
