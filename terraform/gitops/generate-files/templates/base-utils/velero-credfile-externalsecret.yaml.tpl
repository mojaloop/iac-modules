apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${velero_bsl_credentials_secret}
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${velero_bsl_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      type: Opaque
      engineVersion: v2
      data:
        bsl: |
          [default]
          aws_access_key_id =  {{ .AWS_ACCESS_KEY_ID  | toString }}
          aws_secret_access_key = {{ .AWS_SECRET_ACCESS_KEY  | toString }} 

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # TODO: max provider agnostic
      remoteRef: 
        key: ${velero_credentials_secret_provider_key}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${velero_credentials_id_provider_key}
        property: value