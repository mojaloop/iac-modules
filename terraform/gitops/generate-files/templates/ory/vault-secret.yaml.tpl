apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${keto_dsn_secretname}
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
      name: keycloaksecret
      path: /secret/keycloak/${ref_secret_name}
  output:
    name: ${ref_secret_name}
    stringData:
      secret: '{{ .keycloaksecret.${ref_secret_key} }}'
    type: Opaque
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${kratos_dsn_secretname}
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
      name: keycloaksecret
      path: /secret/keycloak/${ref_secret_name}
  output:
    name: ${ref_secret_name}
    stringData:
      secret: '{{ .keycloaksecret.${ref_secret_key} }}'
    type: Opaque