%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: interop-gateway
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${interop_switch_fqdn}'
    port:
      name: https-interop
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}
      mode: MUTUAL
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
%{ if ory_stack_enabled ~}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
%{ else ~}
  action: DENY
%{ endif ~}
  rules:
    - when:
        - key: connection.sni
          values: ["${interop_switch_fqdn}", "${interop_switch_fqdn}:*"]
%{ if !ory_stack_enabled ~}
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/*"]
%{ endif ~}
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: interop-vs
spec:
  gateways:
  - interop-gateway
  hosts:
  - '${interop_switch_fqdn}'
  http:
    - name: participants
      match:
        - uri:
            prefix: /participants
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: parties
      match:
        - uri:
            prefix: /parties
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-api-adapter-service
            port:
              number: 80
%{ if bulk_enabled ~}
    - name: bulkQuotes
      match:
        - uri:
            prefix: /bulkQuotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: bulkTransfers
      match:
        - uri:
            prefix: /bulkTransfers
      route:
        - destination:
            host: ${mojaloop_release_name}-bulk-api-adapter-service
            port:
              number: 80
%{ endif ~}
    - name: transactionRequests
      match:
        - uri:
            prefix: /transactionRequests
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service
            port:
              number: 80
    - name: authorizations
      match:
        - uri:
            prefix: /authorizations
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: int-interop-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${int_interop_switch_fqdn}'
  http:
    - name: participants
      match:
        - uri:
            prefix: /participants
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: parties
      match:
        - uri:
            prefix: /parties
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-api-adapter-service
            port:
              number: 80
%{ if bulk_enabled ~}
    - name: bulkQuotes
      match:
        - uri:
            prefix: /bulkQuotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: bulkTransfers
      match:
        - uri:
            prefix: /bulkTransfers
      route:
        - destination:
            host: ${mojaloop_release_name}-bulk-api-adapter-service
            port:
              number: 80
%{ endif ~}
    - name: transactionRequests
      match:
        - uri:
            prefix: /transactionRequests
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service
            port:
              number: 80
    - name: authorizations
      match:
        - uri:
            prefix: /authorizations
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service
            port:
              number: 80
    - name: central-admin
      match:
        - uri:
            prefix: /admin/
      rewrite:
        uri: /
      route:
        - destination:
            host: ${mojaloop_release_name}-centralledger-service
            port:
              number: 80
    - name: als-admin
      match:
        - uri:
            prefix: /als-admin/
      rewrite:
        uri: /
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service-admin
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mojaloop-ttkfront-vs
spec:
  gateways:
%{ if mojaloop_wildcard_gateway == "external" ~}
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${ttk_frontend_public_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-frontend
            port:
              number: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mojaloop-ttkback-vs
spec:
  gateways:
%{ if mojaloop_wildcard_gateway == "external" ~}
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${ttk_backend_public_fqdn}'
  http:
    - name: api
      match:
        - uri:
            prefix: /api/
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
            port:
              number: 5050
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
            port:
              number: 5050
    - name: root
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
            port:
              number: 4040
---
%{ endif ~}

---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: finance-portal-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${portal_fqdn}'
  http:
    - name: transfers
      match:
        - uri:
            prefix: /api/transfers/
        - uri:
            exact: /api/transfers
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-api-svc
            port:
              number: 80
    - name: central-admin
      match:
        - uri:
            prefix: /api/central-admin/
      rewrite:
        uri: /central-admin/
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-experience-api-svc
            port:
              number: 80
    - name: central-settlements
      match:
        - uri:
            prefix: /api/central-settlements/
      rewrite:
        uri: /v2/
      route:
        - destination:
            host: ${mojaloop_release_name}-centralsettlement-service
            port:
              number: 80
    - name: reports
      match:
        - uri:
            prefix: /api/reports/
        - uri:
            exact: /api/reports
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-legacy-api
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
            host: ${finance_portal_release_name}-reporting-hub-bop-role-ui
            port:
              number: 80
    - name: reporting-hub-bop-trx-ui
      match:
        - uri:
            prefix: /uis/transfers/
        - uri:
            exact: /uis/transfers
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-trx-ui
            port:
              number: 80
    - name: reporting-hub-bop-settlements-ui
      match:
        - uri:
            prefix: /uis/settlements/
        - uri:
            exact: /uis/settlements
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-settlements-ui
            port:
              number: 80
    - name: reporting-hub-bop-positions-ui
      match:
        - uri:
            prefix: /uis/positions/
        - uri:
            exact: /uis/positions
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-positions-ui
            port:
              number: 80
    - name: kratos-woami-redirect
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
    - name: reporting-hub-bop-shell
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-shell
            port:
              number: 80