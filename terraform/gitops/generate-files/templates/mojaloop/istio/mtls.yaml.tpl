apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: mojaMTLS
  namespace: ${mojaloop_namespace}
spec:
  mtls:
    mode: STRICT
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: mojaloop-isolation
  namespace: ${mojaloop_namespace}
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        namespaces: [${mojaloop_namespace}]