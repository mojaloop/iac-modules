apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kratos-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${auth_fqdn}'
  http:
    - match:
        - uri: 
            prefix: /kratos/
      rewrite:
        uri: /
      route:
        - destination:
            host: kratos-public
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kratos-selfservice-ui-node-vs
spec:
  gateways:
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
  hosts:
    - '${auth_fqdn}'
  http:
    - match:
        - uri:
            prefix: /ui/
      rewrite:
        uri: /
      route:
        - destination:
            host: self-service-ui-kratos-selfservice-ui-node
            port:
              number: 80

###

    # hostname:
    # path: /operator(/validate/.*)
    # annotations:
    #   kubernetes.io/ingress.class: nginx
    #   nginx.ingress.kubernetes.io/rewrite-target: $1
    # tls: true
    # selfSigned: true
    # tlsSetSecretManual: true
    # tlsManualSecretName: ""