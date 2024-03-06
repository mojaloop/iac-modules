apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-vs
  namespace: ${argocd_namespace}
spec:
  gateways:
%{ if argocd_wildcard_gateway == "external" ~}
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
    - '${argocd_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: argocd-server
            port:
              number: 80