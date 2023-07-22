apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${keycloak_tls_secretname}
spec:
  secretName: ${keycloak_tls_secretname}
  duration: 696h0m0s
  renewBefore: 360h0m0s
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 2048
  usages:
    - server auth
  commonName: ${keycloak_fqdn}
  dnsNames: 
  - ${keycloak_fqdn}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io