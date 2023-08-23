apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: mcm-gateway
spec:
  selector:
    istio: ${istio_gateway_name}
  servers:
  - hosts:
    - '${mcm_public_fqdn}'
    port:
      name: https-mcm
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-vs
spec:
  gateways:
  - mcm-gateway
  hosts:
  - '${mcm_public_fqdn}'
  http:
  - match:
    - uri: 
      - prefix: /api
    route:
    - destination:
        host: mcm-connection-manager-api
        port:
          number: 3001
  - match:
    - uri: 
      - prefix: /
    route:
    - destination:
        host: mcm-connection-manager-ui
        port:
          number: 8080