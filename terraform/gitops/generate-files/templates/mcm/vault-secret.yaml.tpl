---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${jwt_client_secret_secret}
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
      name: keycloakjwtsecret
      path: /secret/keycloak/${jwt_client_secret_secret}
  output:
    name: ${jwt_client_secret_secret}
    stringData:
      secret: '{{ .keycloakjwtsecret.${jwt_client_secret_secret_key} }}'
    type: Opaque
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${mcm_oidc_client_secret_secret}
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
      name: keycloakmcmsecret
      path: /secret/mcm/${mcm_oidc_client_secret_secret}
  output:
    name: ${mcm_oidc_client_secret_secret}
    stringData:
      secret: '{{ .keycloakmcmsecret.${mcm_oidc_client_secret_secret_key} }}'
    type: Opaque