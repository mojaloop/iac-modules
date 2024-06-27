apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${vault_seal_token_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${vault_seal_token_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: TOKEN # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${vault_seal_token_secret_key}
        property: value
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${vault_oidc_client_id_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${vault_oidc_client_id_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: TOKEN # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${vault_oidc_client_id_secret_key}
        property: value
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${vault_oidc_client_secret_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${vault_oidc_client_secret_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: TOKEN # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${vault_oidc_client_secret_secret_key}
        property: value
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${vault_gitlab_credentials_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${vault_gitlab_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: GITLAB_TOKEN # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${vault_gitlab_credentials_secret_key}
        property: value