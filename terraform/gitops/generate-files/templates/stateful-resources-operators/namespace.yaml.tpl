%{ for stateful_resources_operator in stateful_resources_operators ~}
apiVersion: v1
kind: Namespace
metadata:
  name: ${stateful_resources_operator.namespace}
---
%{ endfor ~}