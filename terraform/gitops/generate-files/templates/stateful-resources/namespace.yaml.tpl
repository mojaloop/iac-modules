%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if ns == "mojaloop" && enable_istio_injection ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}