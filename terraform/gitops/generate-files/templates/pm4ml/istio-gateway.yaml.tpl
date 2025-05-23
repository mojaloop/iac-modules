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
  name: ${admin_portal_release_name}-${pm4ml_release_name}-auth
  namespace: ${pm4ml_istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${pm4ml_istio_gateway_name}
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
  namespace: ${pm4ml_istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${pm4ml_istio_gateway_name}
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
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
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

---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ${pm4ml_release_name}-jwt
  namespace: ${pm4ml_istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${pm4ml_istio_gateway_name}
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