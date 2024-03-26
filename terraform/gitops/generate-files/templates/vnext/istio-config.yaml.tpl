apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: interop-gateway
  annotations:
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
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
            host: ${vnext_release_name}-account-lookup-service
            port:
              number: 80
    - name: parties
      match:
        - uri:
            prefix: /parties
      route:
        - destination:
            host: ${vnext_release_name}-account-lookup-service
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
      route:
        - destination:
            host: ${vnext_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
      route:
        - destination:
            host: ${vnext_release_name}-ml-api-adapter-service
            port:
              number: 80
    - name: transactionRequests
      match:
        - uri:
            prefix: /transactionRequests
      route:
        - destination:
            host: ${vnext_release_name}-transaction-requests-service
            port:
              number: 80
    - name: authorizations
      match:
        - uri:
            prefix: /authorizations
      route:
        - destination:
            host: ${vnext_release_name}-transaction-requests-service
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
            host: ${vnext_release_name}-account-lookup-service
            port:
              number: 80
    - name: parties
      match:
        - uri:
            prefix: /parties
      route:
        - destination:
            host: ${vnext_release_name}-account-lookup-service
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
      route:
        - destination:
            host: ${vnext_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
      route:
        - destination:
            host: ${vnext_release_name}-ml-api-adapter-service
            port:
              number: 80
    - name: transactionRequests
      match:
        - uri:
            prefix: /transactionRequests
      route:
        - destination:
            host: ${vnext_release_name}-transaction-requests-service
            port:
              number: 80
    - name: authorizations
      match:
        - uri:
            prefix: /authorizations
      route:
        - destination:
            host: ${vnext_release_name}-transaction-requests-service
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
            host: ${vnext_release_name}-centralledger-service
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
            host: ${vnext_release_name}-account-lookup-service-admin
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vnext-ttkfront-vs
spec:
  gateways:
%{ if vnext_wildcard_gateway == "external" ~}
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
            host: ${vnext_release_name}-ml-testing-toolkit-frontend
            port:
              number: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: vnext-ttkback-vs
spec:
  gateways:
%{ if vnext_wildcard_gateway == "external" ~}
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
            host: ${vnext_release_name}-ml-testing-toolkit-backend
            port:
              number: 5050
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${vnext_release_name}-ml-testing-toolkit-backend
            port:
              number: 5050
    - name: root
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${vnext_release_name}-ml-testing-toolkit-backend
            port:
              number: 4040
---