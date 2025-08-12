apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_external_gateway_namespace}
  labels:
    istio-injection: enabled
    istio.io/use-waypoint: istio-waypoint
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${istio_internal_gateway_namespace}
  labels:
    istio.io/use-waypoint: istio-waypoint
    istio-injection: enabled
