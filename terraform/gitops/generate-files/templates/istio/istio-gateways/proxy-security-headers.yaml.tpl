apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: proxy-security-headers
  namespace: ${istio_external_gateway_namespace}
spec:
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
    patch:
      operation: INSERT_BEFORE
      value:
        name: security-headers
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.lua.v3.Lua
          # improved on top of https://medium.com/@PatrickSpiegel/secure-by-default-headers-with-envoy-and-istio-5b973ed8b675
          inlineCode: |
            function envoy_on_response(response_handle)
              function hasFrameAncestors(rh)
                s = rh:headers():get("Content-Security-Policy");
                delimiter = ";";
                defined = false;
                for match in (s..delimiter):gmatch("(.-)"..delimiter) do
                  match = match:gsub("%s+", "");
                  if match:sub(1, 15)=="frame-ancestors" then
                    return true;
                  end
                end
                return false;
              end
              if not response_handle:headers():get("Content-Security-Policy") then
                csp = "frame-ancestors none;default-src 'self'";
                response_handle:headers():add("Content-Security-Policy", csp);
              elseif response_handle:headers():get("Content-Security-Policy") then
                if not hasFrameAncestors(response_handle) then
                  csp = response_handle:headers():get("Content-Security-Policy");
                  csp = csp .. ";frame-ancestors none;";
                  response_handle:headers():replace("Content-Security-Policy", csp);
                end
              end
              if not response_handle:headers():get("X-Frame-Options") then
                response_handle:headers():add("X-Frame-Options", "deny");
              end
              if not response_handle:headers():get("X-XSS-Protection") then
                response_handle:headers():add("X-XSS-Protection", "1; mode=block");
              end
              if not response_handle:headers():get("X-Content-Type-Options") then
                response_handle:headers():add("X-Content-Type-Options", "nosniff");
              end
              if not response_handle:headers():get("Referrer-Policy") then
                response_handle:headers():add("Referrer-Policy", "no-referrer");
              end
              if not response_handle:headers():get("X-Download-Options") then
                response_handle:headers():add("X-Download-Options", "noopen");
              end
              if not response_handle:headers():get("X-DNS-Prefetch-Control") then
                response_handle:headers():add("X-DNS-Prefetch-Control", "off");
              end
              if not response_handle:headers():get("Strict-Transport-Security") then
                response_handle:headers():add("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload")
              end
              if not response_handle:headers():get("Feature-Policy") then
                response_handle:headers():add("Feature-Policy",
                                              "camera 'none';"..
                                              "microphone 'none';"..
                                              "geolocation 'none';"..
                                              "encrypted-media 'none';"..
                                              "payment 'none';"..
                                              "speaker 'none';"..
                                              "usb 'none';");
              end
              if response_handle:headers():get("X-Powered-By") then
                response_handle:headers():remove("X-Powered-By");
              end
            end
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
