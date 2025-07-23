# ServiceEntry for wildcard internal domain traffic
%{ if length(internal_wildcard_hosts) > 0 ~}
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: netbird-traffic-wildcard
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
spec:
  hosts:
%{ for host in internal_wildcard_hosts ~}
  - "*.${host}"
%{ endfor ~}
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  - name: tcp
    protocol: TCP
  location: MESH_EXTERNAL
  resolution: DNS
%{ endif ~}
%{ if length(internal_subnets) > 0 ~}
---
# ServiceEntry for internal subnet traffic
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: netbird-traffic-subnets
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
spec:
  addresses:
%{ for subnet in internal_subnets ~}
  - "${subnet}"
%{ endfor ~}
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  - name: tcp
    protocol: TCP
  location: MESH_EXTERNAL
  resolution: NONE
%{ endif ~}
---
# Gateway for Netbird egress traffic
%{ if length(internal_wildcard_hosts) > 0 || length(internal_subnets) > 0 ~}
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: netbird-egress-gateway
  namespace: ${istio_egress_gateway_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
spec:
  selector:
    istio: ${istio_egress_gateway_name}
  servers:
  # HTTPS traffic with SNI passthrough
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
%{ if length(internal_subnets) > 0 ~}
%{ for subnet in internal_subnets ~}
    - "${subnet}"
%{ endfor ~}
%{ endif ~}
    tls:
      mode: PASSTHROUGH
  # All other TCP ports (catch-all including HTTP port 80)
  - port:
      name: tcp
      protocol: TCP
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
%{ if length(internal_subnets) > 0 ~}
%{ for subnet in internal_subnets ~}
    - "${subnet}"
%{ endfor ~}
%{ endif ~}
%{ endif ~}
---
# VirtualService for routing internal domain traffic through Netbird egress gateway
%{ if length(internal_wildcard_hosts) > 0 || length(internal_subnets) > 0 ~}
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: netbird-traffic-egress-vs
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
spec:
  hosts:
%{ for host in internal_wildcard_hosts ~}
  - "*.${host}"
%{ endfor ~}
%{ if length(internal_subnets) > 0 ~}
%{ for subnet in internal_subnets ~}
  - "${subnet}"
%{ endfor ~}
%{ endif ~}
  gateways:
  - mesh
  - ${istio_egress_gateway_namespace}/netbird-egress-gateway
  
  # TCP traffic routing (catches all non-HTTPS ports including HTTP port 80)
  tcp:
  # Route TCP from mesh to egress gateway
  - match:
    - gateways:
      - mesh
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
  
%{ if length(internal_wildcard_hosts) > 0 ~}
  # Route TCP from egress gateway to external destination (hostname-based)
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
    route:
    - destination:
        host: ${internal_wildcard_hosts[0]}
%{ endif ~}
%{ if length(internal_subnets) > 0 ~}
  
  # Route subnet TCP traffic from egress gateway to preserve destination IP
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
      destinationSubnets:
%{ for subnet in internal_subnets ~}
      - "${subnet}"
%{ endfor ~}
    route:
    - destination:
        host: PassthroughCluster
%{ endif ~}
  
%{ if length(internal_wildcard_hosts) > 0 ~}
  # TLS/HTTPS traffic routing with SNI passthrough
  tls:
  # Route HTTPS from mesh to egress gateway
  - match:
    - gateways:
      - mesh
      sniHosts:
%{ for host in internal_wildcard_hosts ~}
      - "*.${host}"
%{ endfor ~}
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: 443
  
  # Route HTTPS from egress gateway to external destination
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
      sniHosts:
%{ for host in internal_wildcard_hosts ~}
      - "*.${host}"
%{ endfor ~}
    route:
    - destination:
        host: ${internal_wildcard_hosts[0]}
        port:
          number: 443
%{ endif ~}
%{ endif ~}
---
# ServiceMonitor for monitoring egress gateway metrics (optional)
%{ if length(internal_wildcard_hosts) > 0 || length(internal_subnets) > 0 ~}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${istio_egress_gateway_name}-monitor
  namespace: ${istio_egress_gateway_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
  labels:
    app: ${istio_egress_gateway_name}
    istio: ${istio_egress_gateway_name}
spec:
  selector:
    matchLabels:
      app: ${istio_egress_gateway_name}
      istio: ${istio_egress_gateway_name}
  endpoints:
  - port: http-monitoring
    interval: 15s
    path: /stats/prometheus
%{ endif ~}
