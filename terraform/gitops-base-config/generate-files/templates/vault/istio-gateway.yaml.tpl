%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: vault-gateway
spec:
  selector:
    istio: ${istio_gateway_name}
  servers:
  - hosts:
    - 'vault.${public_subdomain}'
    port:
      name: https-vault
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vault-vs
spec:
  gateways:
  - vault-gateway
  hosts:
  - 'vault.${public_subdomain}'
  http:
  - match:
    - uri: 
      - prefix: /
    route:
    - destination:
        host: vault-active
        port:
          number: 8200
%{ endif ~}