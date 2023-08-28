apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_external_gateway_namespace}
  annotations: {
    istio-injection: enabled
  }
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_internal_gateway_namespace}
  annotations: {
    istio-injection: enabled
  }