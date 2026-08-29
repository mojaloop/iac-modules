# %{ if istio_create_ingress_gateways }
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
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-account-lookup-service
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-ml-participant-connection-test-svc
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-quoting-service
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-ml-api-adapter-service
# %{ if bulk_enabled }
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-bulk-api-adapter-service
# %{ endif }
    - kind: Service
      group: core
      name: ${mojaloop_release_name}-transaction-requests-service
# %{ if fspiop_use_ory_for_auth }
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
# %{ else }
  action: DENY
# %{ endif }
  rules:
    - to:
        - operation:
            hosts: ["${interop_switch_fqdn}", "${interop_switch_fqdn}:*"]
# %{ if !fspiop_use_ory_for_auth }
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/*"]
# %{ endif }
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
    - name: ping
      match:
        - uri:
            prefix: /ping
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-participant-connection-test-svc
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
        - uri:
            prefix: /fxQuotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
        - uri:
            prefix: /fxTransfers
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-api-adapter-service
            port:
              number: 80
# %{ if bulk_enabled }
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
# %{ endif }
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
    - name: ping
      match:
        - uri:
            prefix: /ping
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-participant-connection-test-svc
            port:
              number: 80
    - name: quotes
      match:
        - uri:
            prefix: /quotes
        - uri:
            prefix: /fxQuotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri:
            prefix: /transfers
        - uri:
            prefix: /fxTransfers
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-api-adapter-service
            port:
              number: 80
# %{ if bulk_enabled }
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
# %{ endif }
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

# %{ if ttk_dev_mode_enabled }
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mojaloop-ttk-vs
spec:
  gateways:
  - ${ttk_istio_gateway_namespace}/${ttk_istio_wildcard_gateway_name}
  hosts:
  - '${ttk_fqdn}'
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
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  form-action 'self';
                  style-src
                    'self'
                    'unsafe-inline'
                    https://use.fontawesome.com
                    https://cdnjs.cloudflare.com
                    https://stackpath.bootstrapcdn.com
                    https://cdn.datatables.net;
                  script-src
                    'self'
                    'unsafe-inline'
                    https://cdnjs.cloudflare.com
                    https://cdn.datatables.net
                    https://code.jquery.com;
                  font-src
                    'self'
                    https://use.fontawesome.com;
                  frame-ancestors
                    'self'
                    https://*.${cluster.domain};
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
            port:
              number: 5050
    - name: frontend
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-frontend
            port:
              number: 6060
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  form-action 'self';
                  style-src
                    'self'
                    'unsafe-inline';
                  connect-src
                    'self'
                    https://api.github.com;
# %{ endif }

---
# %{ endif }

---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: finance-portal-vs
spec:
  gateways:
  - ${portal_istio_gateway_namespace}/${portal_istio_wildcard_gateway_name}
  hosts:
    - '${portal_fqdn}'
  http:
    - name: transfers
      match:
        - uri:
            prefix: /api/transfers/
        - uri:
            exact: /api/transfers
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-api-svc
            port:
              number: 80
    - name: iam
      match:
        - uri:
            prefix: /api/iam/
      rewrite:
        uri: /
      route:
        - destination:
            host: ${finance_portal_release_name}-role-assignment-service
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
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-legacy-api
            port:
              number: 80
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  form-action 'self';
                  style-src-elem
                    'self'
                    'unsafe-inline';
                  img-src
                    'self'
                    data:;
    - name: reporting-hub-bop-role-ui
      match:
        - uri:
            prefix: /uis/iam/
        - uri:
            exact: /uis/iam
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
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-positions-ui
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
    - name: reporting-hub-bop-shell
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${finance_portal_release_name}-reporting-hub-bop-shell
            port:
              number: 80
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  form-action
                    'self'
                    https://${auth_fqdn}/kratos/
                    https://keycloak.${cluster.env}.${cluster.domain}/realms/hub-operators/;
                  style-src
                    'self'
                    'unsafe-inline'
                    https://fonts.googleapis.com;
                  font-src
                    'self'
                    https://fonts.gstatic.com;
                  script-src
                    'self'
                    'unsafe-inline';
                  connect-src
                    'self'
                    https://${auth_fqdn};
                  img-src
                    'self'
                    data:;
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: finance-portal-auth
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${finance_portal_release_name}-reporting-hub-bop-api-svc
    - kind: Service
      group: core
      name: ${finance_portal_release_name}-role-assignment-service
    - kind: Service
      group: core
      name: ${finance_portal_release_name}-reporting-hub-bop-experience-api-svc
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            hosts: ["${portal_fqdn}", "${portal_fqdn}:*"]
---
#adding waypoint for mojaloop ns
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  labels:
    istio.io/waypoint-for: service
  name: service-ingress-waypoint
  namespace: ${mojaloop_namespace}
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
# %{ if cluster.master_node_count + cluster.agent_node_count >= 3 }
  infrastructure:
    parametersRef:
      group: ""
      kind: ConfigMap
      name: service-ingress-waypoint
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: service-ingress-waypoint
data:
  deployment: |
    spec:
      replicas: 3
      template:
        spec:
          topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: "topology.kubernetes.io/zone"
            whenUnsatisfiable: ScheduleAnyway
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
          - maxSkew: 1
            topologyKey: "kubernetes.io/hostname"
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
# %{ endif }

---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: waypoint-connection-pool
  namespace: ${mojaloop_namespace}
spec:
  host: "*.${mojaloop_namespace}.svc.cluster.local"
  trafficPolicy:
    connectionPool:
      http:
        idleTimeout: 4s # default is 1h
      tcp:
        connectTimeout: 5s # default is 10s
