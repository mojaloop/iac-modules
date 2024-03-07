apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${role_assign_svc_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: secret
      path: /secret/keycloak/${role_assign_svc_secret}
  output:
    name: ${role_assign_svc_secret}
    stringData:
      secret: '{{ .secret.${vault_secret_key} }}'
    type: Opaque
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${jws_key_secret}
spec:
  secretName: ${jws_key_secret}
  duration: ${jws_rotation_period_hours}h0m0s
  renewBefore: ${jws_rotation_renew_before_hours}h0m0s
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: ${jws_key_rsa_bits}
    rotationPolicy: Always
  usages:
    - digital signature
    - key encipherment
  commonName: ${interop_switch_fqdn}
  issuerRef:
    name:  ${cert_man_vault_cluster_issuer_name}
    kind: ClusterIssuer
    group: cert-manager.io
  secretTemplate:
    labels:
      reloader: enabled
---