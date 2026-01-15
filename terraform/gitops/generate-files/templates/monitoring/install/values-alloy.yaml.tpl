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