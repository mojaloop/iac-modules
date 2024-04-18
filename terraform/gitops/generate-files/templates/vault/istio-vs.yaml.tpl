%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vault-vs
  annotations:
    argocd.argoproj.io/sync-wave: "${vault_sync_wave}"
spec:
  gateways:
  - ${vault_istio_gateway_namespace}/${vault_istio_wildcard_gateway_name}
  hosts:
  - ${vault_fqdn}
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