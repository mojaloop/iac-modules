%{ if !istio_create_ingress_gateways ~}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ext-mojaloop-ingress
  namespace: ${mojaloop_namespace}
  annotations:
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-secret: ${mojaloop_namespace}/${vault_certman_secretname}
    nginx.ingress.kubernetes.io/auth-url: http://ingress-nginx-validate-jwt.${nginx_jwt_namespace}.svc.cluster.local:8080/auth
spec:
  ingressClassName: ${external_ingress_class_name}
  tls:
    - secretName: ${vault_certman_secretname}
      hosts:
        - ${interop_switch_fqdn}
  rules:
    - host: ${interop_switch_fqdn}
      http:
        paths:
          - path: /participants
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-account-lookup-service
                port:
                  number: 80
          - path: /parties
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-account-lookup-service
                port:
                  number: 80
          - path: /quotes
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-quoting-service
                port:
                  number: 80
          - path: /transfers
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-ml-api-adapter-service
                port:
                  number: 80
          - path: /bulkQuotes
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-quoting-service
                port:
                  number: 80         
          - path: /bulkTransfers
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-bulk-api-adapter-service
                port:
                  number: 80
          - path: /transactionRequests
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-transaction-requests-service
                port:
                  number: 80
          - path: /authorizations
            pathType: ImplementationSpecific
            backend:
              service:
                name: ${mojaloop_release_name}-transaction-requests-service
                port:
                  number: 80
---
%{ endif ~}
