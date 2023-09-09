%{ if !istio_create_ingress_gateways ~}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: ${keycloak_namespace}
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: true
spec:
  ingressClassName: ${ingress_class}
  tls:
    - hosts:
      - ${keycloak_fqdn}
  rules:
    - host: ${keycloak_fqdn}
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${keycloak_name}-service
                port:
                  number: 8443
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress-token
  namespace: ${keycloak_namespace}
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: true
spec:
  ingressClassName: ${external_ingress_class_name}
  tls:
    - hosts:
      - token-${keycloak_fqdn}
  rules:
    - host: token-${keycloak_fqdn}
      http:
        paths:
          - path: /realms/${keycloak_dfsp_realm_name}/protocol/openid-connect
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${keycloak_name}-service
                port:
                  number: 8443
%{ else ~}
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: keycloak-vs
  namespace: ${keycloak_namespace}
spec:
  gateways:
%{ if keycloak_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
    - '${keycloak_fqdn}'
  http:
    - match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${keycloak_name}-service
            port:
              number: 8180
%{ endif ~}