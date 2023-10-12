apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${pm4ml_oidc_client_secret_secret}
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
      name: keycloakpm4mlsecret
      path: /secret/keycloak/${pm4ml_oidc_client_secret_secret}
  output:
    name: ${pm4ml_oidc_client_secret_secret}
    stringData:
      secret: '{{ .keycloakpm4mlsecret.${pm4ml_oidc_client_secret_secret_key} }}'
    type: Opaque