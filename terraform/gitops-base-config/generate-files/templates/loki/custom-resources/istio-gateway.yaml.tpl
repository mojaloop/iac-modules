%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana-gateway
spec:
  selector:
    istio: ${istio_gateway_name}
  servers:
  - hosts:
    - 'grafana.${public_subdomain}'
    port:
      name: https-grafana
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana-vs
spec:
  gateways:
    - grafana-gateway
  hosts:
    - 'grafana.${public_subdomain}'
  http:
    - match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: loki-app-grafana
            port:
              number: 80
%{ endif ~}