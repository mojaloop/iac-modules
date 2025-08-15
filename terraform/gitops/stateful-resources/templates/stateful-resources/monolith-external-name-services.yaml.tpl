%{ for logical_service_name, external_name in config ~}
---
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: ${logical_service_name}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${service_entry_sync_wave}"
  labels:
    istio.io/use-waypoint: egress-waypoint
    istio.io/use-waypoint-namespace: istio-system
spec:
  hosts:
  - ${logical_service_name}.${stateful_resources_namespace}.svc.cluster.local
  location: MESH_EXTERNAL
  resolution: DNS
  ports:
  - number: 3306
    name: mysql
    protocol: TCP
  - number: 27017
    name: mongodb
    protocol: TCP
  endpoints:
  - address: ${external_name}
%{ endfor ~}