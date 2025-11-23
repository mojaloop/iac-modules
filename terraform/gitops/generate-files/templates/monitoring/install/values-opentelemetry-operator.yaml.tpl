manager:
  collectorImage:
    repository: ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-k8s
%{if length(tolerations) > 0 ~}
tolerations:
%{ for line in split("\n", yamlencode(tolerations)) ~}
  ${indent(2,line)}
%{ endfor ~}
%{endif ~}