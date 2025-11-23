manager:
  collectorImage:
    repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s
tolerations:
  ${indent(4, yamlencode(tolerations))}