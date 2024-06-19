---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${pm4ml_release_name}-connector-gateway-a
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${inter_scheme_proxy_adapter_a_fqdn}'
    port:
      name: https-connector
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}-scheme-a
      mode: MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${pm4ml_release_name}-connector-gateway-b
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${inter_scheme_proxy_adapter_b_fqdn}'
    port:
      name: https-connector
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}-scheme-b
      mode: MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-connector-vs-a
spec:
  gateways:
  - ${pm4ml_release_name}-connector-gateway-a
  hosts:
  - '${inter_scheme_proxy_adapter_a_fqdn}'
  http:
    - name: "inter-scheme-proxy-adapter"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-inter-scheme-proxy-adapter
            port:
              number: 4100
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-connector-vs-b
spec:
  gateways:
  - ${pm4ml_release_name}-connector-gateway-b
  hosts:
  - '${inter_scheme_proxy_adapter_b_fqdn}'
  http:
    - name: "inter-scheme-proxy-adapter"
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-inter-scheme-proxy-adapter
            port:
              number: 4000

---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkfront-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
  hosts:
  - '${ttk_frontend_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-frontend
            port:
              number: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkback-vs
spec:
  gateways:
  - ${pm4ml_istio_gateway_namespace}/${pm4ml_istio_wildcard_gateway_name}
  hosts:
  - '${ttk_backend_fqdn}'
  http:
    - name: api
      match:
        - uri:
            prefix: /api/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: socket
      match:
        - uri:
            prefix: /socket.io/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: root
      match:
        - uri:
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 4040

---
