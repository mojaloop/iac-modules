apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${external_dns_credentials_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 1h

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${external_dns_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      type: Opaque
      engineVersion: v2
      data:
        # multiline string
        credentials: |
          [default]
          aws_access_key_id = {{ .AWS_ACCESS_KEY_ID }}
          aws_secret_access_key = {{ .AWS_SECRET_ACCESS_KEY }}

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${external_dns_credentials_secret_provider_key}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${external_dns_credentials_id_provider_key}
        property: value