---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: pm4ml-ui-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${portal_fqdn}'
  http:
    - name: "portal"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: pm4ml-frontend
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: pm4ml-experience-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${experience_api_fqdn}'
  http:
    - name: "experience-api"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: pm4ml-experience-api
            port:
              number: 80
          headers:
            response:
              add:
                access-control-allow-origin: "https://${portal_fqdn}"
                access-control-allow-credentials: "true"
%{ if pm4ml_wildcard_gateway == "external" ~} 
---
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: keycloak-${keycloak_pm4ml_realm_name}-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      istio: ${istio_external_gateway_name}
  jwtRules:
  - issuer: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}"
    jwksUri: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/protocol/openid-connect/certs"
    fromHeaders:
      - name: Authorization
        prefix: "Bearer "
%{ endif ~}