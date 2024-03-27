### hack, this needs to be removed once vnext services are configured with individual mongo user/password/host/etc
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${vnext_mongo_url_secret_name}
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
      path: ${vnext_mongo_secret_path}
  output:
    name: ${vnext_mongo_url_secret_name}
    stringData:
      url: 'mongodb://${vnext_mongodb_user}:{{ .secret.password }}@${vnext_mongodb_host}:${vnext_mongodb_port}/${vnext_mongodb_database}'
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