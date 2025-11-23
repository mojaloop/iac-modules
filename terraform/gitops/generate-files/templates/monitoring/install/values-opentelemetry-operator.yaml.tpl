manager:
  collectorImage:
    repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s
%{if length(tolerations) > 0 ~}
tolerations:
  ${indent(2, yamlencode(tolerations))}
%{endif ~}