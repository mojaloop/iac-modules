apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${longhorn_credentials_secret}
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: gitlab-secret-store

  target:
    name: ${longhorn_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${gitlab_key_longhorn_backups_secret_key}
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${gitlab_key_longhorn_backups_access_key}