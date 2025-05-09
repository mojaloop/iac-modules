apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${netbird_operator_api_key_secret}
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${netbird_operator_api_key_secret}
    creationPolicy: Owner
    template:
      data:
        NB_API_KEY: "{{ .NB_API_KEY  | toString }}"

  data:
    - secretKey: NB_API_KEY
      remoteRef:
        key: ${netbird_operator_api_key_vault_path}
        property: value