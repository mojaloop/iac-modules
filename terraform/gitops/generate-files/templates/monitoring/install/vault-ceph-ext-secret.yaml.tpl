apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${object_store_loki_credentials_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${object_store_loki_credentials_secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: CEPH_LOKI_USERNAME
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: ${object_store_loki_user_key}
        property: value
    - secretKey: CEPH_LOKI_PASSWORD
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: ${object_store_loki_password_key}
        property: value

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${object_store_tempo_credentials_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${object_store_tempo_credentials_secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
  # https://grafana.com/docs/tempo/latest/configuration/hosted-storage/s3/#amazon-s3-permissions
    - secretKey: AWS_ACCESS_KEY_ID
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: ${object_store_tempo_user_key}
        property: value
    - secretKey: AWS_SECRET_ACCESS_KEY
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: ${object_store_tempo_password_key}
        property: value