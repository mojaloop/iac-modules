apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: loki-credentials-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: loki-credentials-secret # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: MINIO_LOKI_USERNAME
      remoteRef: 
        key: ${minio_loki_secret_credentials_ref}
        property: username
    - secretKey: MINIO_LOKI_PASSWORD
      remoteRef: 
        key: ${minio_loki_secret_credentials_ref}
        property: password
