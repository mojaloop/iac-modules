---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-vs
spec:
  gateways:
  - ${mcm_istio_gateway_namespace}/${mcm_istio_wildcard_gateway_name}
  hosts:
  - '${mcm_fqdn}'
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
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mcm-jwt
  namespace: ${mcm_istio_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${mcm_istio_gateway_name}
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths: ["/api/*", "/pm4mlapi/*"]
            hosts: ["${mcm_fqdn}", "${mcm_fqdn}:*"]