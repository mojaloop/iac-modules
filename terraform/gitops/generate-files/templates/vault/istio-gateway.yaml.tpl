%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vault-vs
  annotations:
    argocd.argoproj.io/sync-wave: "${vault_sync_wave}"
spec:
  gateways:
%{ if vault_wildcard_gateway == "external" ~}
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - 'vault.${public_subdomain}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: vault-active
            port:
              number: 8200
%{ endif ~}