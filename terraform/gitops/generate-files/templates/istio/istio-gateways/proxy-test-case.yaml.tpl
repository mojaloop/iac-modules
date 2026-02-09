apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: egress-payload-blocker
  namespace: ${istio_external_gateway_namespace}
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_OUTBOUND
    patch:
      operation: INSERT_BEFORE
      value:
        name: egress-payload-blocker
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
          inlineCode: |
            function envoy_on_request(request_handle)
              local testcase_header = request_handle:headers():get("x-testcase");
              if testcase_header == "block-request" then
                request_handle:respond(
                  {[":status"] = "403"},
                  "Egress request blocked: x-testcase header detected"
                );
              end
            end
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
