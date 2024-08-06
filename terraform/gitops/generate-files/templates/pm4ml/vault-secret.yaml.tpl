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
      secret: '{{ .keycloakpm4mlsecret.${vault_secret_key} }}'
    type: Opaque
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${pm4ml_external_switch_client_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${pm4ml_external_switch_client_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      metadata:
        labels:
          reloader: enabled

  data:
    - secretKey: ${pm4ml_external_switch_client_secret_key} # Key given to the secret to be created on the cluster
      remoteRef:
        key: ${pm4ml_external_switch_client_secret_vault_key}
        property: ${pm4ml_external_switch_client_secret_vault_value}
---
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
