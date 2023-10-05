apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${istio_internal_wildcard_gateway_name}
  namespace: ${istio_internal_gateway_namespace}
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${internal_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_internal_gateway_name}
  servers:
  - hosts:
    - '${keycloak_admin_fqdn}'
%{ if loki_wildcard_gateway == "internal" ~} 
    - 'grafana.${public_subdomain}'
%{ endif ~}
%{ if vault_wildcard_gateway == "internal" ~} 
    - 'vault.${public_subdomain}'
%{ endif ~}
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${istio_external_wildcard_gateway_name}
  namespace: ${istio_external_gateway_namespace}
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${keycloak_fqdn}'
%{ if loki_wildcard_gateway == "external" ~} 
    - 'grafana.${public_subdomain}'
%{ endif ~}
%{ if vault_wildcard_gateway == "external" ~} 
    - 'vault.${public_subdomain}'
%{ endif ~}
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE