
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: interop-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
%{ if fspiop_use_ory_for_auth ~}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
%{ else ~}
  action: DENY
%{ endif ~}
  rules:
    - to:
        - operation:
            hosts: ["${interop_switch_fqdn}", "${interop_switch_fqdn}:*"]
%{ if !fspiop_use_ory_for_auth ~}
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/*"]
%{ endif ~}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: finance-portal-auth
  namespace: ${portal_istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${portal_istio_gateway_name}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths:
              - /api/*
            hosts: ["${portal_fqdn}", "${portal_fqdn}:*"]