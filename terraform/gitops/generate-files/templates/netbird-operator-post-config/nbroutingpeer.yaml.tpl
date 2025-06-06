apiVersion: netbird.io/v1
kind: NBRoutingPeer
metadata:
  finalizers:
    - netbird.io/cleanup
  labels:
    app.kubernetes.io/component: operator
    app.kubernetes.io/instance: netbird-operator
    app.kubernetes.io/name: kubernetes-operator
  name: router
  namespace: ${netbird_operator_namespace}
spec: {}
