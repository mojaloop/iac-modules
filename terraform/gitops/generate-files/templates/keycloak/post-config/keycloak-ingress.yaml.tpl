%{ if !istio_create_ingress_gateways ~}
%{ set nginx_configuration_snippet = "proxy_set_header X-Forwarded-Proto $scheme;\n      proxy_set_header X-Forwarded-Port $server_port;\n      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" ~}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: ${keycloak_namespace}
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: true
    nginx.ingress.kubernetes.io/configuration-snippet: |
      ${nginx_configuration_snippet}
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
    nginx.ingress.kubernetes.io/configuration-snippet: |
      ${nginx_configuration_snippet}
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
  name: keycloak-ext-vs
spec:
  gateways:
  - ${keycloak_istio_gateway_namespace}/${keycloak_istio_wildcard_gateway_name}
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
              number: 8443
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: keycloak-admin-vs
spec:
  gateways:
  - ${keycloak_admin_istio_gateway_namespace}/${keycloak_admin_istio_wildcard_gateway_name}
  hosts:
  - '${keycloak_admin_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${keycloak_name}-service
            port:
              number: 8443
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: keycloak
  namespace: ${keycloak_namespace}
spec:
  host: ${keycloak_name}-service
  trafficPolicy:
    tls:
      mode: SIMPLE
%{ endif ~}