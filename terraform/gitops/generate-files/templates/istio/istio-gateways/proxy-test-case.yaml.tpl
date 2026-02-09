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
              local baggage_header = request_handle:headers():get("baggage");
              if baggage_header ~= nil then
                for pair in baggage_header:gmatch("[^,]+") do
                  local key, value = pair:match("^%s*([^=]+)=(.*)$");
                  if key == "test-instruction" and value == "block-request" then
                    request_handle:respond(
                      {[":status"] = "403"},
                      "Egress request blocked: test-instruction=block-request in baggage header detected"
                    );
                    return;
                  end
                end
              end
            end
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
