# ServiceEntry for wildcard internal domain traffic (ambient mode with waypoint)
# Dynamic ServiceEntry creation across multiple namespaces for selective waypoint routing
%{ if length(internal_wildcard_hosts) > 0 ~}
%{ for namespace in netbird_target_namespaces ~}
# ServiceEntry in ${namespace} namespace
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: netbird-traffic-wildcard
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
  labels:
%{ if namespace == "istio-system" ~}
    istio.io/use-waypoint: waypoint
%{ else ~}
    istio.io/use-waypoint: waypoint
    istio.io/use-waypoint-namespace: istio-system
%{ endif ~}
spec:
  hosts:
%{ for host in internal_wildcard_hosts ~}
  - "*.${host}"
%{ endfor ~}
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
%{ if length(tcp_ports) > 0 ~}
%{ for port in tcp_ports ~}
  - number: ${port}
    name: tcp-${port}
    protocol: TCP
%{ endfor ~}
%{ endif ~}
  location: MESH_EXTERNAL
  resolution: NONE
---
%{ endfor ~}
---
apiVersion: netbird.io/v1
kind: NBSetupKey
metadata:
  name: netbird-egress-routing
  namespace: istio-system
spec:
  managementURL: ${netbird_management_url}
  secretKeyRef:
    name: ${netbird_setup_key_secret_name}
    key: ${netbird_setup_key_secret_key}
---
# Waypoint proxy for ambient mode egress routing (cross-namespace with netbird sidecar)
%{ if length(internal_wildcard_hosts) > 0 ~}
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: waypoint
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
    netbird.io/setup-key: netbird-egress-routing
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
    allowedRoutes:
      namespaces:
        from: All  # Allow cross-namespace usage
%{ endif ~}
