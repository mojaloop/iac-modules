apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-vs
  namespace: ${argocd_namespace}
spec:
  gateways:
%{ if argocd_as_external_svc ~}  
    - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ endif ~}
%{ if argocd_as_internal_svc ~}  
   - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name} 
%{ endif ~}
%{ if ! argocd_as_internal_svc and ! argocd_as_external_svc ~}  
   - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name} 
%{ endif ~}
  hosts:
%{ if argocd_as_external_svc ~}    
    - '${argocd_public_fqdn}'
%{ endif ~}
%{ if argocd_as_internal_svc ~}  
    - '${argocd_private_fqdn}'
%{ endif ~}    
%{ if ! argocd_as_internal_svc and ! argocd_as_external_svc ~}  
    - '${argocd_private_fqdn}'
%{ endif ~}  
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