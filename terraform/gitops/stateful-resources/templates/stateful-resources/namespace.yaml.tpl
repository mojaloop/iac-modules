%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
  %{ if or (eq ns "mojaloop") (eq ns "mcm") ~}
  labels:
    istio-injection: enabled
  %{ endif ~}
---
%{ endfor ~}