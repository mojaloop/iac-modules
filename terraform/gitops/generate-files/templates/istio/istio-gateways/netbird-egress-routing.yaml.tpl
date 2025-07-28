# ServiceEntry for wildcard internal domain traffic (ambient mode with waypoint)
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
  # Use waypoint for egress routing in ambient mode
  workloadSelector:
    labels:
      gateway.istio.io/managed: istio.io-gateway-controller
%{ endif ~}
---
# VirtualService for routing through egress gateway (applied to waypoint)
%{ if length(internal_wildcard_hosts) > 0 ~}
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
  gateways:
  - mesh
  - ${istio_egress_gateway_namespace}/netbird-egress-gateway
  
  # HTTP traffic routing via egress gateway
  http:
  # Route from mesh to egress gateway
  - match:
    - gateways:
      - mesh
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: 80
  
  # Route from egress gateway to external destination (with netbird sidecar)
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
    route:
    - destination:
        host: ${internal_wildcard_hosts[0]}
        port:
          number: 80

%{ if length(tcp_ports) > 0 ~}
  # TCP traffic routing for configured ports
  tcp:
%{ for port in tcp_ports ~}
  # Route TCP port ${port} from mesh to egress gateway
  - match:
    - gateways:
      - mesh
      port: ${port}
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: ${port}
  
  # Route TCP port ${port} from egress gateway to external destination
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
      port: ${port}
    route:
    - destination:
        host: ${internal_wildcard_hosts[0]}
        port:
          number: ${port}
%{ endfor ~}
%{ endif ~}

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
---
# Egress Gateway configuration (assumes netbird sidecar is configured separately)
%{ if length(internal_wildcard_hosts) > 0 ~}
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
  # HTTP traffic (port 80)
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
  # HTTPS traffic with SNI passthrough
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
    tls:
      mode: PASSTHROUGH
%{ if length(tcp_ports) > 0 ~}
%{ for port in tcp_ports ~}
  # TCP port ${port}
  - port:
      number: ${port}
      name: tcp-${port}
      protocol: TCP
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
%{ endfor ~}
%{ endif ~}
%{ endif ~}
---
# Waypoint proxy for ambient mode egress gateway routing (cross-namespace)
%{ if length(internal_wildcard_hosts) > 0 ~}
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: waypoint
  namespace: istio-system
  annotations:
    argocd.argoproj.io/sync-wave: "${istio_gateways_sync_wave}"
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
---
# ServiceMonitor for monitoring egress gateway metrics (optional)
%{ if length(internal_wildcard_hosts) > 0 ~}
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
