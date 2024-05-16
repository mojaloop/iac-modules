%{ for ns in distinct(stateful_resources_operators[*].namespace) ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${ns}
---
%{ endfor ~}