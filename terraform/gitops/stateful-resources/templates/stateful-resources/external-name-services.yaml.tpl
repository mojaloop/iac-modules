%{ for logical_service_name, external_name in config ~}
---
apiVersion: v1
kind: Service
metadata:
  name: ${logical_service_name}
  namespace: ${stateful_resources_namespace}
spec:
  type: ExternalName
  externalName: ${external_name}
%{ if service_entry_required ~}
---
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: ${logical_service_name}-se
  namespace: ${stateful_resources_namespace}
spec:
  hosts:
    - ${logical_service_name}
  location: MESH_EXTERNAL
  resolution: DNS
  ports:
    - number: 3306
      name: mysql
      protocol: TCP
    - number: 27017
      name: mongodb
      protocol: TCP
%{ endif ~}
%{ endfor ~}