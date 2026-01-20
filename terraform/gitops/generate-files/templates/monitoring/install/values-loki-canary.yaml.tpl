
# ServiceMonitor configuration
serviceMonitor:
  enabled: true

lokiAddress: loki-grafana-loki-gateway:80

%{if length(tolerations) > 0 ~}
tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{endif ~}