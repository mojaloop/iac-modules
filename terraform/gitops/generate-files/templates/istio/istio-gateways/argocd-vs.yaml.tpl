%{ if argocd_as_external_svc == "true" ~}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-external-vs
  namespace: ${argocd_namespace}
spec:
  gateways:
    - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${argocd_public_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: argocd-server
            port:
              number: 80
---                    
%{ endif ~}                
%{ if argocd_as_internal_svc == "true" ~}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-internal-vs
  namespace: ${argocd_namespace}
spec:
  gateways:
    - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}  
  hosts:
    - '${argocd_private_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: argocd-server
            port:
              number: 80
---                    
%{ endif ~}                 
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: argocd-server-dtrl
  namespace: ${argocd_namespace}
spec:
  host: argocd-server
  trafficPolicy:
    tls:
      mode: SIMPLE                