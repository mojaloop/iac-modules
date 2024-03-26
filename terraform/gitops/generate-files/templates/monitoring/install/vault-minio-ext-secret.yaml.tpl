apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${minio_credentials_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${minio_credentials_secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: MINIO_LOKI_USERNAME
      remoteRef: 
        key: ${minio_loki_user_key}
        property: value 
    - secretKey: MINIO_LOKI_PASSWORD
      remoteRef: 
        key: ${minio_loki_password_key}
        property: value