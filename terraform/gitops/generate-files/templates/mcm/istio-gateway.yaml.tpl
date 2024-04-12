---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-vs
spec:
  gateways:
    - ${istio_gateway_namespace}/${istio_wildcard_gateway_name}
  hosts:
     - ${mcm_fqdn}
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
    - name: "pm4mlapi"
      match:
        - uri:
            prefix: /pm4mlapi
      rewrite:
        uri: /api
      route:
        - destination:
            host: mcm-connection-manager-api
            port:
              number: 3001
    - name: kratos-logout-proxy
      match:
        - uri:
            prefix: /kratos/self-service/logout/browser
      rewrite:
        uri: /self-service/logout/browser
      route:
        - destination:
            host: ${kratos_service_name}
            port:
              number: 80
    - name: kratos-whoami-proxy
      match:
        - uri:
            prefix: /kratos/sessions/whoami
      rewrite:
        uri: /sessions/whoami
      route:
        - destination:
            host: ${kratos_service_name}
            port:
              number: 80
    - name: "ui"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: mcm-connection-manager-ui
            port:
              number: 8080
#%{ if mcm_wildcard_gateway == "external" ~}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mcm-jwt
  namespace: ${istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_gateway_name}
%{ if ory_stack_enabled ~}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
%{ else ~}
  action: DENY
%{ endif ~}
  rules:
    - to:
        - operation:
            paths: ["/api/*", "/pm4mlapi/*"]
            hosts: ["${mcm_fqdn}", "${mcm_fqdn}:*"]
%{ if !ory_stack_enabled ~}
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/*"]
%{ endif ~}
%{ if !ory_stack_enabled ~}
---
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: keycloak-${keycloak_dfsp_realm_name}-jwt
  namespace: ${istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      istio: ${istio_gateway_name}
  jwtRules:
  - issuer: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}"
    jwksUri: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs"
    fromHeaders:
      - name: Authorization
        prefix: "Bearer "
      - name: Cookie
        prefix: "MCM_SESSION"
%{ endif ~}
#%{ endif ~}