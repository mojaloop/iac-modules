apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: proxy-protocol
  namespace: istio-system
spec:
  configPatches:
  - applyTo: LISTENER_FILTER
    patch:
      operation: INSERT_FIRST
      value:
        name: proxy_protocol
        typed_config:
          "@type": "type.googleapis.com/envoy.extensions.filters.listener.proxy_protocol.v3.ProxyProtocol"
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: health-check
  namespace: istio-system
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '*'
    port:
      name: http
      number: 80
      protocol: HTTP2
  - hosts:
    - '*'
    port:
      name: https
      number: 443
      protocol: HTTP2
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: health-check
  namespace: istio-system
spec:
  gateways:
  - istio-system/health-check
  hosts:
  - "*"
  http:
  - name: "health-check"
    match:
    - uri:
        prefix: "/healthz/ready"
    route:
    - destination:
        host: ${istio_external_gateway_name}
        port:
          number: 15021