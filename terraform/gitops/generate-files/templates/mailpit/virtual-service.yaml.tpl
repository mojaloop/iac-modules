apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mailpit-ui
  namespace: ${mailpit_namespace}
spec:
  gateways:
    - ${mailpit_istio_internal_gateway_namespace}/${mailpit_istio_internal_wildcard_gateway_name}
  hosts:
    - "mailpit.${mailpit_internal_dns_subdomain}"
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: mailpit-http
            port:
              number: 80