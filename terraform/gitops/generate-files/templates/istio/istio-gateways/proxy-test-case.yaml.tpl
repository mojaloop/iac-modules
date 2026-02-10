apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ingress-payload-blocker
  namespace: ${istio_external_gateway_namespace}
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
    patch:
      operation: INSERT_BEFORE
      value:
        name: ingress-payload-blocker
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
          inlineCode: |
            function envoy_on_request(request_handle)
              local baggage_header = request_handle:headers():get("baggage")
              if baggage_header ~= nil then
                for pair in baggage_header:gmatch("[^,]+") do
                  local key, value = pair:match("^%s*([^=]+)%s*=%s*(.-)%s*$")
                  if key and key == "test-instruction" and value then
                    local method = request_handle:headers():get(":method") or ""
                    local path = request_handle:headers():get(":path") or ""
                    if value == "block-fulfil" then
                      if method == "PUT" then
                        if path:match("^/transfers/[^/]+$") or path:match("^/transfers/[^/]+/error$") then
                          request_handle:respond(
                            {[":status"] = "403"},
                            "Ingress request blocked: test-instruction=block-fulfil for PUT /transfers/{ID} or /transfers/{ID}/error"
                          )
                          return
                        end
                      end
                    elseif value == "block-fx-fulfil" then
                      if method == "PUT" then
                        if path:match("^/fxTransfers/[^/]+$") or path:match("^/fxTransfers/[^/]+/error$") then
                          request_handle:respond(
                            {[":status"] = "403"},
                            "Ingress request blocked: test-instruction=block-fx-fulfil for PUT /fxTransfers/{ID} or /fxTransfers/{ID}/error"
                          )
                          return
                        end
                      end
                    end
                  end
                end
              end
            end
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
