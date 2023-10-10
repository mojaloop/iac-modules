apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${vault_certman_secretname}
  namespace: ${pm4ml_namespace}
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
  commonName: ${callback_fqdn}
  dnsNames: 
  - ${callback_fqdn}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io