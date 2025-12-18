# first disable all grafana comms with an allow nothing policy
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-nothing
  namespace: istio-system
spec:
  action: ALLOW
  rules:
    - from:
        - source:
            notServiceAccounts:
              - monitoring/grafana-sa
---
# then enable individual policies for tempo, loki, prometheus
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-tempo
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: grafana-tempo
  action: ALLOW
  rules:
    - from:
        - source:
            serviceAccounts:
              - monitoring/grafana-sa
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-loki
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: grafana-loki
  action: ALLOW
  rules:
    - from:
        - source:
            serviceAccounts:
              - monitoring/grafana-sa
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-loki-v2
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: loki
  action: ALLOW
  rules:
    - from:
        - source:
            serviceAccounts:
              - monitoring/grafana-sa
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: grafana-allow-prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  action: ALLOW
  rules:
    - from:
        - source:
            serviceAccounts:
              - monitoring/grafana-sa
