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
    - to: # /api is first checked by the mcm-jwt CUSTOM policy below, but needs to be allowed here too
        - operation:
            hosts:
              - ${mcm_fqdn}
              - ${mcm_fqdn}:*
              - ${mcm_external_fqdn}
              - ${mcm_external_fqdn}:*
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
            hosts:
              - ${mcm_fqdn}
              - ${mcm_fqdn}:*
              - ${mcm_external_fqdn}
              - ${mcm_external_fqdn}:*
