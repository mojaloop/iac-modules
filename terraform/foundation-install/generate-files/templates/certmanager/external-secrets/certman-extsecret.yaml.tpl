apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${cert_manager_credentials_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: gitlab-secret-store

  target:
    name: ${cert_manager_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${cert_manager_credentials_secret_provider_key}
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${cert_manager_credentials_id_provider_key}