grafana:
  enabled: false
operator:
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
