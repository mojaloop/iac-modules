%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if enable_istio_injection ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}