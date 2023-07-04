apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: wildcard-cert-internal
  namespace: default
  annotations:
    argocd.argoproj.io/sync-wave: "-8"
spec:
  secretName: ${default_ssl_certificate}
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
  commonName: ${public_subdomain}
  dnsNames:
    - "${public_subdomain}"
    - "*.${public_subdomain}"