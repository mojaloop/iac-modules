manager:
  collectorImage:
    repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s
  resources:
    requests:
      cpu: 50m
      memory: 128Mi
    limits:
      cpu: 100m
      memory: 256Mi
%{if length(tolerations) > 0 ~}
tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}
