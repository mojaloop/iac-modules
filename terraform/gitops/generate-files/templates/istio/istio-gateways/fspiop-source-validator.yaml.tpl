apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: fspiop-source-validator
  namespace: ${istio_external_gateway_namespace}
spec:
  workloadSelector:
    labels:
      istio: ${istio_external_gateway_name}
  configPatches:
    - applyTo: HTTP_FILTER
      match:
        context: GATEWAY
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
              
                -- Skip if x_client_id header missing                                                                                                                                         
                if x_client_id == nil then                                                                                                                                            
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
