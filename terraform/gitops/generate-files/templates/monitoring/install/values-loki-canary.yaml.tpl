
# ServiceMonitor configuration
serviceMonitor:
  enabled: true

lokiAddress: loki-grafana-loki-gateway:80

%{if length(tolerations) > 0 ~}
tolerations:
  ${indent(2, yamlencode(tolerations))}
%{endif ~}