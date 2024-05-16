%{ for ns in stateful_resources_operators_ns ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
---
%{ endfor ~}