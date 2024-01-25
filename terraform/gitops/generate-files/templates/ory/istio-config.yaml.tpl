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
            prefix: /kratos/
      rewrite:
        uri: /
      route:
        - destination:
            host: kratos-public
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: self-service-ui-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${auth_fqdn}'
  http:
    - match:
        - uri:
            prefix: /selfui/auth/
      rewrite:
        uri: /
      route:
        - destination:
            host: self-service-ui-security-hub-bop-kratos-ui
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: oathkeeper-proxy-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${auth_fqdn}'
  http:
    - match:
        - uri:
            prefix: /proxy/
      rewrite:
        uri: /
      route:
        - destination:
            host: oathkeeper-proxy
            port:
              number: 4455
