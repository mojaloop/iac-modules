replicas: ${metrics_server_replicas}
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 200m
    memory: 512Mi
defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls

%{if length(tolerations) > 0 ~}
tolerations:
%{ for t in tolerations ~}
  - effect: "${t.effect}"
    key: "${t.key}"
    operator: "${t.operator}"
    value: "${t.value}"
%{ endfor ~}
%{ endif ~}
