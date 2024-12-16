%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if ns in ["mojaloop", "mcm"] ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}