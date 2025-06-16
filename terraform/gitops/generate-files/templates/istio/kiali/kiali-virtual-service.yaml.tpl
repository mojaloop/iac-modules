apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali-vs
spec:
  gateways:
  - ${kiali_istio_gateway_namespace}/${kiali_istio_wildcard_gateway_name}
  hosts:
  - '${kiali_fqdn}'
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: kiali
            port:
              number: 20001