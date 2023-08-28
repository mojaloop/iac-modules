%{ if !istio_create_ingress_gateways ~}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: ${keycloak_namespace}
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: true
spec:
  ingressClassName: ${ingress_class}
  tls:
    - hosts:
      - ${keycloak_fqdn}
  rules:
    - host: ${keycloak_fqdn}
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${keycloak_name}-service
                port:
                  number: 8443
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress-token
  namespace: ${keycloak_namespace}
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/ssl-passthrough: true
spec:
  ingressClassName: ${external_ingress_class_name}
  tls:
    - hosts:
      - token-${keycloak_fqdn}
  rules:
    - host: token-${keycloak_fqdn}
      http:
        paths:
          - path: /realms/${keycloak_dfsp_realm_name}/protocol/openid-connect
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${keycloak_name}-service
                port:
                  number: 8443
%{ else ~}
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: keycloak-gateway
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${loadbalancer_host_name}
  }
spec:
  selector:
    istio: ${istio_gateway_name}
  servers:
  - hosts:
    - '${keycloak_fqdn}'
    - 'token-${keycloak_fqdn}'
    port:
      name: https-keyloak
      number: 443
      protocol: HTTPS
    tls:
      mode: PASSTHROUGH
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: keycloak-vs
spec:
  gateways:
  - keycloak-gateway
  hosts:
  - '${keycloak_fqdn}'
  - 'token-${keycloak_fqdn}'
  tls:
  - match:
    - port: 443
      sniHosts:
      - ${keycloak_fqdn}
    route:
    - destination:
        host: ${keycloak_name}-service
        port:
          number: 8443
  - match:
    - port: 443
      sniHosts:
      - token-${keycloak_fqdn}
    route:
    - destination:
        host: ${keycloak_name}-service
        port:
          number: 8443
%{ endif ~}