%{ for logical_service_name, external_name in config ~}
---
apiVersion: v1
kind: Service
metadata:
  name: ${logical_service_name}
spec:
  type: ExternalName
  externalName: ${external_name}
%{ endfor ~}