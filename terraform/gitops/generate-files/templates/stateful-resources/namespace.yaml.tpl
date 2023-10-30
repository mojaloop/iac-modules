%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
%{ if ns == "mojaloop" ~}
  labels:
    istio-injection: enabled
%{ endif ~}
---
%{ endfor ~}