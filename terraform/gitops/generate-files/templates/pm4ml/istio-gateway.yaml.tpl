---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ui-vs
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
    - name: "portal"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-frontend
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${admin_portal_release_name}-${pm4ml_namespace}-admin-ui-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~}
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${admin_portal_fqdn}'
  http:
    - name: iam
      match:
        - uri:
            prefix: /api/iam/
      rewrite:
        uri: /
      route:
        - destination:
            host: ${admin_portal_release_name}-role-assignment-service
            port:
              number: 80
    - name: reporting-hub-bop-role-ui
      match:
        - uri:
            prefix: /uis/iam/
        - uri:
            exact: /uis/iam
      rewrite:
        uri: /
      route:
        - destination:
            host: ${admin_portal_release_name}-reporting-hub-bop-role-ui
            port:
              number: 80
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
    - name: "portal"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${admin_portal_release_name}-reporting-hub-bop-shell
            port:
              number: 80
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${admin_portal_release_name}-${pm4ml_namespace}-auth
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths:
              - /api/*
            hosts: ["${admin_portal_fqdn}", "${admin_portal_fqdn}:*"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-exp-auth
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths:
              - /*
            hosts: ["${experience_api_fqdn}", "${experience_api_fqdn}:*"]
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-experience-vs
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
            host: ${pm4ml_release_name}-experience-api
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
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
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
            paths: ["/api/*"]
            hosts: ["${portal_fqdn}", "${portal_fqdn}:*"]
%{ if !ory_stack_enabled ~}
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/*"]
%{ endif ~}
%{ if !ory_stack_enabled ~}
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
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${pm4ml_release_name}-connector-gateway
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${mojaloop_connnector_fqdn}'
    port:
      name: https-connector
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}
      mode: MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-connector-vs
spec:
  gateways:
  - ${pm4ml_release_name}-connector-gateway
  hosts:
  - '${mojaloop_connnector_fqdn}'
  http:
    - name: "mojaloop-connector"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4000
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-test-vs
spec:
  gateways:
    - istio-ingress-int/internal-wildcard-gateway
  hosts:
    - '${test_fqdn}'
  http:
    - name: "sim-backend"
      match:
        - uri:
            prefix: /sim-backend-test(/|$)(.*)
      route:
        - destination:
            host: sim-backend
            port:
              number: 3003
    - name: "mojaloop-core-connector"
      match:
        - uri:
            prefix: /cc-send(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-mojaloop-core-connector
            port:
              number: 3003
    - name: "mlcon-outbound"
      match:
        - uri:
            prefix: /mlcon-outbound
      rewrite:
        uri: /
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4001
    - name: "mlcon-sdktest"
      match:
        - uri:
            prefix: /mlcon-sdktest(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4002
    - name: "mgmt-api"
      match:
        - uri:
            prefix: /mgmt-api(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-management-api
            port:
              number: 9050
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkfront-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${ttk_frontend_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-frontend
            port:
              number: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkback-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${ttk_backend_fqdn}'
  http:
    - name: api
      match:
        - uri:
            prefix: /api/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: root
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 4040

---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-portal-pta-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${pta_portal_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-mojaloop-payment-token-adapter
            port:
              number: 3000
---
%{ endif ~}