grafana:
  enabled: false
operator:
  image:
    registry: ghcr.io
    repository: grafana/grafana-operator
    tag: v5.6.0
    pullPolicy: IfNotPresent
  command: ["/ko-app/v5"] # NOTE: helm chart is defaulting to 'grafana-operator' command. Overriding to default container entrypoint
  args: []
  nodeAffinityPreset:
    type: hard
    key: workload-class.mojaloop.io/MONITORING
    values: ["enabled"]
  resources:
    requests:
      cpu: 20m
      memory: 100Mi
%{if length(tolerations) > 0 ~}
  tolerations:
${indent(4, yamlencode(tolerations))}
%{endif ~}
