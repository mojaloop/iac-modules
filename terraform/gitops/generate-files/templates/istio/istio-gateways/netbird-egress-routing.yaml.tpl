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
  resolution: DNS
%{ endif ~}
---
# Gateway for Netbird egress traffic
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
# VirtualService for routing internal domain traffic through Netbird egress gateway
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
  
  # HTTP traffic routing
  http:
  # Route HTTP from mesh to egress gateway
  - match:
    - gateways:
      - mesh
      headers:
        ":authority":
          regex: ".*\\.${replace(internal_wildcard_hosts[0], ".", "\\\\.")}(:[0-9]+)?$"
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: 80
    headers:
      request:
        set:
          x-netbird-route: "mesh-to-egress"
          x-egress-gateway: "${istio_egress_gateway_name}"
  
  # Route HTTP from egress gateway to external destination
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
    route:
    - destination:
        host: ${internal_wildcard_hosts[0]}
        port:
          number: 80
    headers:
      request:
        set:
          x-netbird-route: "egress-to-external"
  
  # TCP traffic routing for configured ports
%{ if length(tcp_ports) > 0 ~}
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
