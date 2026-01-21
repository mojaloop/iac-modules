# values: https://github.com/grafana/alloy/blob/helm-chart/1.4.0/operations/helm/charts/alloy/values.yaml

alloy:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: ${alloy_limits_cpu}
      memory: ${alloy_limits_memory}
  configMap:
    create: false
    name: alloy-config
    key: alloy-config.alloy

controller:
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
%{ else ~}
  tolerations: []
%{ endif ~}