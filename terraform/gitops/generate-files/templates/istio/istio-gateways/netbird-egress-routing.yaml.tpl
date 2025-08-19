# ServiceEntry for internal domain traffic (ambient mode with waypoint)
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: netbird-traffic-wildcard
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
  labels:
    istio.io/use-waypoint: ${istio_egress_waypoint_name}
    istio.io/use-waypoint-namespace: ${istio_egress_waypoint_namespace}
spec:
  exportTo:
    - "*" # Make it available mesh-wide
  hosts:
%{ for host in netbird_traffic_hosts ~}
  - "${host}"
%{ endfor ~}
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
---
# Waypoint proxy for ambient mode egress routing (cross-namespace with netbird sidecar)
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: ${istio_egress_waypoint_name}
  namespace: ${istio_egress_waypoint_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
    netbird.io/setup-key: ${netbird_setup_key_name}
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
    allowedRoutes:
      namespaces:
        from: All  # Allow cross-namespace usage
