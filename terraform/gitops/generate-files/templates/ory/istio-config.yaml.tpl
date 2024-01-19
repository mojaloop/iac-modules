apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kratos-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${auth_fqdn}'
  http:
    - match:
        - uri: 
            prefix: /kratos
      route:
        - destination:
            host: kratos-public
            port:
              number: 80