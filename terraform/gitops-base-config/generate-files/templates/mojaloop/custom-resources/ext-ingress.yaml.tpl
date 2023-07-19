---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ext-mojaloop-ingress
  namespace: ${mojaloop_namespace}
  annotations:
    nginx.ingress.kubernetes.io/auth-tls-verify-client: "on"
    nginx.ingress.kubernetes.io/auth-tls-secret: ${mojaloop_namespace}/${vault_certman_secretname}
    #nginx.ingress.kubernetes.io/auth-url: http://ingress-nginx-validate-jwt.${nginx_jwt_namespace}.svc.cluster.local:8080/auth?tid=11111111-1111-1111-1111-111111111111&aud=22222222-2222-2222-2222-222222222222&aud=33333333-3333-3333-3333-333333333333
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
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${vault_certman_secretname}
  namespace: ${mojaloop_namespace}
spec:
  secretName: ${vault_certman_secretname}
  duration: 696h0m0s
  renewBefore: 360h0m0s
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - digital signature
    - key encipherment
    - client auth
  commonName: ${interop_switch_fqdn}
  dnsNames: 
  - ${interop_switch_fqdn}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io