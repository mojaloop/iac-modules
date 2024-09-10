%{ for ns in all_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
# tried to implement OR operator but couldn't find a syntax for it.
  %{ if ns == "mojaloop" ~}
  labels:
    istio-injection: enabled
  %{ endif ~}
  %{ if ns == "mcm" ~}
  labels:
    istio-injection: enabled
  %{ endif ~}
---
%{ endfor ~}