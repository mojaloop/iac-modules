grafana:
  enabled: false
operator:
  image:
    registry: ghcr.io
    repository: grafana/grafana-operator
    tag: v5.6.0
    pullPolicy: IfNotPresent
  command: ["/ko-app/v5"]
  args: []
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
