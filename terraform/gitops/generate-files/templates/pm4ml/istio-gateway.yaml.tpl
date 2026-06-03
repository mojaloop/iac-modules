apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  labels:
    istio.io/waypoint-for: service
  name: service-ingress-waypoint
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
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
      replicas: ${pm4ml_service_ingress_waypoint_replicas}
      template:
        spec:
          topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: "kubernetes.io/hostname"
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ui-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
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
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  form-action
                    'self'
                    https://${auth_fqdn}/kratos/
                    https://keycloak.${cluster.env}.${cluster.domain}/realms/;
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
                    https://${auth_fqdn}
                    https://${experience_api_fqdn};
                  img-src
                    'self'
                    https://img.icons8.com
                    data:;
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${admin_portal_release_name}-${pm4ml_namespace}-admin-ui-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
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
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
                  font-src 'self' https://fonts.gstatic.com;
                  script-src 'self' 'unsafe-inline';
                  connect-src 'self' ${auth_fqdn} ${experience_api_fqdn};
                  img-src 'self' https://img.icons8.com data:;
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${admin_portal_release_name}-${pm4ml_release_name}-auth
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${admin_portal_release_name}-role-assignment-service
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            hosts: ["${admin_portal_fqdn}", "${admin_portal_fqdn}:*"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-exp-auth
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${pm4ml_release_name}-experience-api
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            hosts: ["${experience_api_fqdn}", "${experience_api_fqdn}:*"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-management-api-auth
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${pm4ml_release_name}-management-api
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            hosts: ["${experience_api_fqdn}", "${experience_api_fqdn}:*"]
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-experience-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
  hosts:
  - '${experience_api_fqdn}'
  http:
    - name: "management-api-cors-preflight"
      match:
        - uri:
            prefix: /states
          method:
            exact: OPTIONS
        - uri:
            prefix: /reonboard
          method:
            exact: OPTIONS
        - uri:
            prefix: /recreate
          method:
            exact: OPTIONS
      directResponse:
        status: 204
      headers:
        response:
          set:
            access-control-allow-origin: "https://${portal_fqdn}"
            access-control-allow-credentials: "true"
            access-control-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
            access-control-allow-headers: "Content-Type, Authorization"
            access-control-max-age: "86400"
    - name: "management-api"
      match:
        - uri:
            prefix: /states
        - uri:
            prefix: /reonboard
        - uri:
            prefix: /recreate
      route:
        - destination:
            host: ${pm4ml_release_name}-management-api
            port:
              number: 80
          headers:
            response:
              set:
                access-control-allow-origin: "https://${portal_fqdn}"
                access-control-allow-credentials: "true"
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
              set:
                access-control-allow-origin: "https://${portal_fqdn}"
                access-control-allow-credentials: "true"

---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-jwt
spec:
  targetRefs:
    - kind: Service
      group: core
      name: ${pm4ml_release_name}-frontend
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths: ["/api/*"]
            hosts: ["${portal_fqdn}", "${portal_fqdn}:*"]
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
# %{ if ttk_enabled }
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttk-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
  hosts:
  - '${ttk_fqdn}'
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
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  style-src 'self' 'unsafe-inline' https://use.fontawesome.com https://cdnjs.cloudflare.com https://stackpath.bootstrapcdn.com https://cdn.datatables.net;
                  script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://cdn.datatables.net https://code.jquery.com;
                  font-src 'self' https://use.fontawesome.com;
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: frontend
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-frontend
            port:
              number: 6060
          headers:
            response:
              set:
                Content-Security-Policy:
                  default-src 'self';
                  style-src 'self' 'unsafe-inline';
                  connect-src 'self' https://api.github.com;
                  frame-ancestors 'self' *.${cluster.domain};
---
# %{ endif }
# %{ if payment_token_adapter_config.enabled}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-portal-pta-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
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
#%{ endif}
