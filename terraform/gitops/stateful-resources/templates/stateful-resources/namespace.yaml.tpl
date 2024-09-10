%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
  %{ if ns == "mojaloop" or ns == "mcm" ~}
  labels:
    istio-injection: enabled
  %{ endif ~}
---
%{ endfor ~}