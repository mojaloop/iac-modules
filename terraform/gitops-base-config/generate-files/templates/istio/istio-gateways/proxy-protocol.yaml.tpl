apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: proxy-protocol
  namespace: ${istio_external_gateway_namespace}
spec:
  configPatches:
  - applyTo: LISTENER
    patch:
      operation: MERGE
      value:
        listener_filters:
        - name: envoy.listener.proxy_protocol
        - name: envoy.listener.tls_inspector
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: health-check
  namespace: ${istio_external_gateway_namespace}
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
  namespace: ${istio_external_gateway_namespace}
spec:
  gateways:
  - health-check
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