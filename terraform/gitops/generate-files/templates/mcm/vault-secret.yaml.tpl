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
# Hub Operators OIDC Client Secret (for MCM user authentication flows)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${hubop_oidc_client_secret_secret}
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
      name: hubopoidcsecret
      path: /secret/keycloak/${hubop_oidc_client_secret_secret}
  output:
    name: ${hubop_oidc_client_secret_secret}
    stringData:
      secret: '{{ .hubopoidcsecret.secret }}'
    type: Opaque
---
# MCM Admin Client Secret (for Keycloak administrative operations)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${mcm_admin_client_secret_name}
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
      name: apisecret
      path: /secret/keycloak/${mcm_admin_client_secret_name}
  output:
    name: ${mcm_admin_client_secret_name}
    stringData:
      secret: '{{ .apisecret.secret }}'
    type: Opaque


