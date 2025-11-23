
# ServiceMonitor configuration
serviceMonitor:
  enabled: true

lokiAddress: loki-grafana-loki-gateway:80

%{if length(tolerations) > 0 ~}
tolerations:
%{ for line in split("\n", yamlencode(tolerations)) ~}
  ${indent(2,line)}
%{ endfor ~}
%{endif ~}