%{ if istio_authorization_enabled ~}
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: account-lookup-service-policy
spec:
  selector:
    matchLabels:
      app: ${mojaloop_release_name}-account-lookup-service
  rules:
  - from:
    - source:
        principals: ["*"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/participants*", "/parties*"]
---

%{ endif ~}