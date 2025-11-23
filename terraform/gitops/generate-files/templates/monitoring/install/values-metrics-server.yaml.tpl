replicas: ${metrics_server_replicas}
defaultArgs:
  - --cert-dir=/tmp
  - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
  - --kubelet-use-node-status-port
  - --metric-resolution=15s
  - --kubelet-insecure-tls

%{if length(tolerations) > 0 ~}
tolerations:
%{ for line in split("\n", yamlencode(tolerations)) ~}
  ${indent(2,line)}
%{ endfor ~}
%{endif ~}