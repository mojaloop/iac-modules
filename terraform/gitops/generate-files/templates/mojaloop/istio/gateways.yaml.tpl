%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: interop-gateway
  annotations:
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${interop_switch_fqdn}'
    port:
      name: https-interop
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}
      mode: MUTUAL
---
%{ endif ~}