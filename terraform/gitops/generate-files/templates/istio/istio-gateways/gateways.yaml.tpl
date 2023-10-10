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
%{ for host in internal_gateway_hosts ~}
    - '${host}'
%{ endfor ~}
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
%{ for host in external_gateway_hosts ~}
    - '${host}'
%{ endfor ~}
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE