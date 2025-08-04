apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mailhog-ui
  namespace: ${mailhog_namespace}
spec:
  gateways:
    - ${mailhog_istio_internal_gateway_namespace}/${mailhog_istio_internal_wildcard_gateway_name}
  hosts:
    - "mailhog.${mailhog_internal_dns_subdomain}"
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: mailhog
            port:
              number: 8025