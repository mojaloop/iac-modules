apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-mcm
spec:
  targetRefs:
    - kind: Service
      group: core
      name: mcm-connection-manager-api
  action: ALLOW
  rules:
    - from:
        - source:
            serviceAccounts:
              - monitoring/grafana-sa
      to:
        - operation:
            paths:
              - /api/dfsps/states-status
    - from: # /api is first checked by the mcm-jwt CUSTOM policy below
        - source:
            serviceAccounts:
              - ${mcm_istio_gateway_namespace}/${mcm_istio_gateway_name}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: mcm-jwt
spec:
  targetRefs:
    - kind: Service
      group: core
      name: mcm-connection-manager-api
  action: CUSTOM
  provider:
    name: ${oathkeeper_auth_provider_name}
  rules:
    - to:
        - operation:
            paths:
              - /api/{**}
    - from:
        - source:
            serviceAccounts:
              - ${mcm_istio_gateway_namespace}/${mcm_istio_gateway_name}
