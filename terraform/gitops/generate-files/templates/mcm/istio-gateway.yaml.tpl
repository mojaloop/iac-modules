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
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mcm-external-vs
spec:
  gateways:
  - ${mcm_istio_external_gateway_namespace}/${mcm_istio_external_wildcard_gateway_name}
  hosts:
  - '${mcm_external_fqdn}'
  http:
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
#temporary fix for waypoint
---
# Waypoint proxy for ambient mode egress routing (cross-namespace with netbird sidecar)
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: egress-waypoint
  namespace: ${mojaloop_namespace}
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: egress-waypoint-cert-access
  namespace: ${mojaloop_namespace}
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: egress-waypoint-cert-access-binding
  namespace: ${mojaloop_namespace}
subjects:
- kind: ServiceAccount
  name: egress-waypoint
  namespace: ${mojaloop_namespace}
roleRef:
  kind: Role
  name: egress-waypoint-cert-access
  apiGroup: rbac.authorization.k8s.io