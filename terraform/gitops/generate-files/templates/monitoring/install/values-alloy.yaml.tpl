# values: https://github.com/grafana/alloy/blob/helm-chart/1.4.0/operations/helm/charts/alloy/values.yaml

alloy:
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi
  configMap:
    create: false
    name: external-alloy-config
    key: config.alloy