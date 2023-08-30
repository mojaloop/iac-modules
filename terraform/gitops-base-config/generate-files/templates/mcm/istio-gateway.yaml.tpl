apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-vs
spec:
  gateways:
%{ if mcm_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${mcm_public_fqdn}'
  http:
    - name: "api"
      match:
        - uri: 
            prefix: /api
      route:
        - destination:
            host: mcm-connection-manager-api
            port:
              number: 3001
    - name: "ui"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: mcm-connection-manager-ui
            port:
              number: 8080