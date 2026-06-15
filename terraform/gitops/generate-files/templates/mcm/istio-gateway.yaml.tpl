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
  name: ${istio_ml_egress_waypoint_name}
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
# %{ if cluster.master_node_count + cluster.agent_node_count >= 3 }
  infrastructure:
    parametersRef:
      group: ""
      kind: ConfigMap
      name: ml-egress-waypoint
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: ml-egress-waypoint
  namespace: mojaloop
data:
  deployment: |
    spec:
      replicas: 3
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxSurge: 0
          maxUnavailable: 1
      template:
        spec:
          topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: "topology.kubernetes.io/zone"
            whenUnsatisfiable: ScheduleAnyway # Hard requirement for AZ spread
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: ml-egress-waypoint
          - maxSkew: 1
            topologyKey: "kubernetes.io/hostname"
            whenUnsatisfiable: DoNotSchedule # Hard requirement for node spread
            labelSelector:
              matchLabels:
                gateway.networking.k8s.io/gateway-name: ml-egress-waypoint
# %{ endif }
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${istio_ml_egress_waypoint_name}-cert-access
  namespace: ${mojaloop_namespace}
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${istio_ml_egress_waypoint_name}-cert-access-binding
  namespace: ${mojaloop_namespace}
subjects:
- kind: ServiceAccount
  name: ${istio_ml_egress_waypoint_name}
  namespace: ${mojaloop_namespace}
roleRef:
  kind: Role
  name: ${istio_ml_egress_waypoint_name}-cert-access
  apiGroup: rbac.authorization.k8s.io
