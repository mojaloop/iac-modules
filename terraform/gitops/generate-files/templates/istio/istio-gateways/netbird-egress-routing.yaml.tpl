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
  hosts:
  - istio-subnet-dummy.local
  addresses:
%{ for subnet in internal_subnets ~}
  - "${subnet}"
%{ endfor ~}
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
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
  # HTTP traffic (port 80)
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
%{ if length(internal_subnets) > 0 && length(internal_wildcard_hosts) == 0 ~}
    - "istio-subnet-dummy.local"
%{ endif ~}
  # HTTPS traffic with SNI passthrough
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
%{ for host in internal_wildcard_hosts ~}
    - "*.${host}"
%{ endfor ~}
%{ if length(internal_subnets) > 0 && length(internal_wildcard_hosts) == 0 ~}
    - "istio-subnet-dummy.local"
%{ endif ~}
    tls:
      mode: PASSTHROUGH
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
%{ if length(internal_subnets) > 0 && length(internal_wildcard_hosts) == 0 ~}
  - "istio-subnet-dummy.local"
%{ endif ~}
  gateways:
  - mesh
  - ${istio_egress_gateway_namespace}/netbird-egress-gateway
  
  # HTTP traffic routing (for ambient mode compatibility)
  http:
  # Route HTTP from mesh to egress gateway (hostname-based)
%{ if length(internal_wildcard_hosts) > 0 ~}
  - match:
    - gateways:
      - mesh
      headers:
        ":authority":
          regex: ".*\\.${replace(internal_wildcard_hosts[0], ".", "\\.")}(:[0-9]+)?$"
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: 80
    headers:
      request:
        set:
          x-netbird-route: "mesh-to-egress-hostname"
          x-debug-timestamp: "%START_TIME%"
          x-egress-gateway: "${istio_egress_gateway_name}"
          x-virtualservice: "netbird-traffic-egress-vs"
%{ endif ~}
%{ if length(internal_subnets) > 0 ~}
  
  # Route HTTP from mesh to egress gateway (subnet-based)
  - match:
    - gateways:
      - mesh
      headers:
        ":authority":
          regex: "^([0-9]{1,3}\\.){3}[0-9]{1,3}(:[0-9]+)?$"
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
        port:
          number: 80
    headers:
      request:
        set:
          x-netbird-route: "mesh-to-egress-subnet"
          x-debug-timestamp: "%START_TIME%"
          x-egress-gateway: "${istio_egress_gateway_name}"
          x-virtualservice: "netbird-traffic-egress-vs"
          x-subnet-routing: "true"
%{ endif ~}
  
%{ if length(internal_wildcard_hosts) > 0 ~}
  # Route HTTP from egress gateway to external destination (hostname-based)
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
          x-netbird-route: "egress-to-external-hostname"
          x-netbird-gateway: "${istio_egress_gateway_name}"
%{ endif ~}
%{ if length(internal_subnets) > 0 ~}
  
  # Route HTTP from egress gateway for subnet traffic (IP-based)
  - match:
    - gateways:
      - ${istio_egress_gateway_namespace}/netbird-egress-gateway
      headers:
        ":authority":
          regex: "^([0-9]{1,3}\\.){3}[0-9]{1,3}(:[0-9]+)?$"
    route:
    - destination:
        host: PassthroughCluster
    headers:
      request:
        set:
          x-netbird-route: "egress-to-external-subnet"
          x-netbird-passthrough: "true"
          x-debug-source: "%DOWNSTREAM_REMOTE_ADDRESS%"
          x-debug-destination: "%UPSTREAM_HOST%"
%{ endif ~}
  
  # TCP traffic routing (catches all non-HTTP/HTTPS ports)
  # Note: TCP routes in VirtualService automatically handle all protocols
  # that are not HTTP or HTTPS, as documented in Istio TCP routing
  tcp:
%{ if length(internal_subnets) > 0 ~}
  # Route TCP from mesh to egress gateway (subnet-based)
  - match:
    - gateways:
      - mesh
      destinationSubnets:
%{ for subnet in internal_subnets ~}
      - "${subnet}"
%{ endfor ~}
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
%{ endif ~}
%{ if length(internal_wildcard_hosts) > 0 ~}
  
  # Route TCP from mesh to egress gateway (fallback for hostname traffic)
  - match:
    - gateways:
      - mesh
    route:
    - destination:
        host: ${istio_egress_gateway_name}.${istio_egress_gateway_namespace}.svc.cluster.local
%{ endif ~}
  
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
