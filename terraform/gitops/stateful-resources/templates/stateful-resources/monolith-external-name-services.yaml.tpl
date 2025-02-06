%{ for logical_service_name, external_name in config ~}
---
apiVersion: v1
kind: Service
metadata:
  name: ${logical_service_name}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"     
spec:
  type: ExternalName
  externalName: ${external_name}
%{ endfor ~}