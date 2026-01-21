# Request flow:
#   1. Request arrives at external gateway
#   2. Routed to waypoint proxy (service-ingress-waypoint)
#   3. ext_authz (Oathkeeper) validates JWT and adds x-client-id header
#   4. THIS FILTER compares fspiop-source with x-client-id
#   5. Request proceeds to backend service
#
# Known limitation: EnvoyFilter support for waypoints in ambient mode is incomplete
# See: https://github.com/istio/istio/issues/43720
#      https://github.com/istio/istio/discussions/53014
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: fspiop-source-validator
  namespace: ${mojaloop_namespace}
spec:
  workloadSelector:
    labels:
      gateway.networking.k8s.io/gateway-name: service-ingress-waypoint
  configPatches:
    - applyTo: HTTP_FILTER
      match:
        # Use ANY context for waypoint proxies (not GATEWAY or SIDECAR_INBOUND)
        context: ANY
        listener:
          filterChain:
            filter:
              name: "envoy.filters.network.http_connection_manager"
              subFilter:
                name: "envoy.filters.http.ext_authz"
      patch:
        operation: INSERT_AFTER  # MUST be AFTER ext_authz (Oathkeeper)
        value:
          name: fspiop-source-validator
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
            inlineCode: |
              function envoy_on_request(request_handle)
                local fspiop_source = request_handle:headers():get("fspiop-source") or ""
                local x_client_id = request_handle:headers():get("x-client-id")

                -- Skip if x-client-id header missing (no JWT auth or unauthenticated request)
                if x_client_id == nil then
                  request_handle:logInfo("No x-client-id header found, skip fspiop-source-validator")
                  return
                end

                -- Case-insensitive comparison
                if string.lower(fspiop_source) ~= string.lower(x_client_id) then
                  request_handle:logWarn(string.format(
                    "FSPIOP-Source mismatch: fspiop_source=%s, x_client_id=%s",
                    fspiop_source, x_client_id
                  ))
                  request_handle:respond(
                    {[":status"] = "403"},
                    "FSPIOP-Source does not match authenticated client_id"
                  )
                end
              end
