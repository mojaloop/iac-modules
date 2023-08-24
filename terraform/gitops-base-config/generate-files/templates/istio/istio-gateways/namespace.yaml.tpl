apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_external_gateway_namespace}
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_internal_gateway_namespace}