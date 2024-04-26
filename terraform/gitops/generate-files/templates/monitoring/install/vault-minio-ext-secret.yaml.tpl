apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${minio_loki_credentials_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${minio_loki_credentials_secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: MINIO_LOKI_USERNAME
      remoteRef: 
        conversionStrategy: Default	
        decodingStrategy: None	
        key: ${minio_loki_user_key}
        property: value 
    - secretKey: MINIO_LOKI_PASSWORD
      remoteRef: 
        conversionStrategy: Default	
        decodingStrategy: None	      
        key: ${minio_loki_password_key}
        property: value   

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${minio_tempo_credentials_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${minio_tempo_credentials_secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
  # https://grafana.com/docs/tempo/latest/configuration/hosted-storage/s3/#amazon-s3-permissions
    - secretKey: MINIO_ACCESS_KEY
      remoteRef: 
        conversionStrategy: Default	
        decodingStrategy: None	
        key: ${minio_tempo_user_key}
        property: value 
    - secretKey: MINIO_SECRET_KEY
      remoteRef: 
        conversionStrategy: Default	
        decodingStrategy: None	      
        key: ${minio_tempo_password_key}
        property: value           