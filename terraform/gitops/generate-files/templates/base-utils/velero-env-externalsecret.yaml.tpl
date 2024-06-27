apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${velero_credentials_secret}
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${velero_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      data:
        AWS_ENDPOINTS: http://${minio_api_url}/
        AWS_SECRET_ACCESS_KEY: "{{ .AWS_SECRET_ACCESS_KEY  | toString }}"
        AWS_ACCESS_KEY_ID: "{{ .AWS_ACCESS_KEY_ID  | toString }}"

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # TODO: max provider agnostic
      remoteRef: 
        key: ${velero_credentials_secret_provider_key}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${velero_credentials_id_provider_key}
        property: value