grafana:
  enabled: false
operator:
  image:
    registry: ghcr.io
    repository: grafana/grafana-operator
    tag: v5.10.0
    pullPolicy: IfNotPresent
  command: ["/manager"] 
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
