apiVersion: v1
kind: Namespace
metadata:
  name: ${keycloak_namespace}
  annotations: {
    istio-injection: enabled
  }