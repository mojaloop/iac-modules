apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ${istio_internal_gateway_name}-keep-alive
  namespace: ${istio_internal_gateway_namespace}
spec:
  workloadSelector:
    labels:
      istio: ${istio_internal_gateway_name}
  configPatches:
  - applyTo: LISTENER
    match:
      context: GATEWAY
    patch:
      operation: MERGE
      value:
        socket_options:
        - description: enable keep-alive
          int_value: 1
          level: 1
          name: 9
          state: STATE_PREBIND
        - description: idle time before first keep-alive probe is sent
          int_value: 7
          level: 6
          name: 4
          state: STATE_PREBIND
        - description: keep-alive interval
          int_value: 5
          level: 6
          name: 5
          state: STATE_PREBIND
        - description: keep-alive probes count
          int_value: 2
          level: 6
          name: 6
          state: STATE_PREBIND
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ${istio_external_gateway_name}-keep-alive
  namespace: ${istio_external_gateway_namespace}
spec:
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
  configPatches:
  - applyTo: LISTENER
    match:
      context: GATEWAY
    patch:
      operation: MERGE
      value:
        socket_options:
        - description: enable keep-alive
          int_value: 1
          level: 1
          name: 9
          state: STATE_PREBIND
        - description: idle time before first keep-alive probe is sent
          int_value: 7
          level: 6
          name: 4
          state: STATE_PREBIND
        - description: keep-alive interval
          int_value: 5
          level: 6
          name: 5
          state: STATE_PREBIND
        - description: keep-alive probes count
          int_value: 2
          level: 6
          name: 6
          state: STATE_PREBIND
