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
