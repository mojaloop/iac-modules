%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if istio_create_ingress_gateways ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}