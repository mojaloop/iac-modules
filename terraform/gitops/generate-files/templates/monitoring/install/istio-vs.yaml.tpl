%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana-vs
spec:
  gateways:
  - ${grafana_istio_gateway_namespace}/${grafana_istio_wildcard_gateway_name}
  hosts:
  - ${grafana_fqdn}
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: grafana-service
            port:
              number: 3000
          headers:
            response:
              add:
                Content-Security-Policy: "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: alertmanager-vs
spec:
  gateways:
  - ${grafana_istio_gateway_namespace}/${grafana_istio_wildcard_gateway_name}
  hosts:
  - ${alertmanager_fqdn}
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: alertmanager-operated
            port:
              number: 9093
          headers:
            response:
              add:
                Content-Security-Policy: "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"

%{ endif ~}
