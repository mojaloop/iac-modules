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
      path: /secret/keycloak/${mcm_oidc_client_secret_secret}
  output:
    name: ${mcm_oidc_client_secret_secret}
    stringData:
      secret: '{{ .keycloakmcmsecret.${mcm_oidc_client_secret_secret_key} }}'
    type: Opaque
---
# API Service Client Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: keycloak-${keycloak_dfsp_realm_name}-realm-api-secret
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
      name: realm-secrets
      path: /secret/keycloak/${keycloak_dfsp_realm_name}-realm-secrets
  output:
    name: keycloak-${keycloak_dfsp_realm_name}-realm-api-secret
    stringData:
      secret: '{{ .realm-secrets.api-service-client-secret }}'
    type: Opaque
---
# Auth Client Secret  
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: keycloak-${keycloak_dfsp_realm_name}-realm-auth-secret
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
      name: realm-secrets
      path: /secret/keycloak/${keycloak_dfsp_realm_name}-realm-secrets
  output:
    name: keycloak-${keycloak_dfsp_realm_name}-realm-auth-secret
    stringData:
      secret: '{{ .realm-secrets.auth-client-secret }}'
    type: Opaque
---
# SMTP User Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: mcm-smtp-credentials
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
      name: smtpcreds
      path: /secret/mcm/smtp-credentials
  output:
    name: mcm-smtp-credentials
    stringData:
      secret: '{{ .smtpcreds.smtp_user }}'
    type: Opaque
---
# SMTP Password Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: mcm-smtp-password-credentials
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
      name: smtpcreds
      path: /secret/mcm/smtp-credentials
  output:
    name: mcm-smtp-password-credentials
    stringData:
      secret: '{{ .smtpcreds.smtp_password }}'
    type: Opaque


