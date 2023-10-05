apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${istio_internal_mojaloop_wildcard_gateway_name}
  namespace: ${istio_internal_gateway_namespace}
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${internal_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_internal_gateway_name}
  servers:
  - hosts:
    - '${int_interop_switch_fqdn}'
%{ if mojaloop_wildcard_gateway == "internal" ~} 
    - 'ttkfrontend.${public_subdomain}'
    - 'ttkbackend.${public_subdomain}'
%{ endif ~}
%{ if mcm_wildcard_gateway == "internal" ~} 
    - '${mcm_public_fqdn}'
%{ endif ~}
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${istio_external_mojaloop_wildcard_gateway_name}
  namespace: ${istio_external_gateway_namespace}
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
%{ if mojaloop_wildcard_gateway == "external" ~} 
    - 'ttkfrontend.${public_subdomain}'
    - 'ttkbackend.${public_subdomain}'
%{ endif ~}
%{ if mcm_wildcard_gateway == "external" ~} 
    - '${mcm_public_fqdn}'
%{ endif ~}
    port:
      name: https
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-vs
spec:
  gateways:
%{ if mcm_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_mojaloop_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_mojaloop_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${mcm_public_fqdn}'
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
    - name: "ui"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: mcm-connection-manager-ui
            port:
              number: 8080
%{ if mcm_wildcard_gateway == "external" ~} 
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mcm-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
  action: DENY
  rules:
    - to:
        - operation:
            paths: ["/api/*"]
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/*"]
      when:
        - key: connection.sni
          values: ["${mcm_public_fqdn}", "${mcm_public_fqdn}:*"]
---
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: keycloak-${keycloak_dfsp_realm_name}-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      istio: ${istio_external_gateway_name}
  jwtRules:
  - issuer: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}"
    jwksUri: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect/certs"
    fromHeaders:
      - name: Authorization
        prefix: "Bearer "
      - name: Cookie
        prefix: "MCM_SESSION"
%{ endif ~}