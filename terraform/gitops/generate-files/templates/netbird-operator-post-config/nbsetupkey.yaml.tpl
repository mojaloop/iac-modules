apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${netbird_setup_key_secret_name}
  namespace: istio-system
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${netbird_setup_key_secret_name}
    creationPolicy: Owner
    template:
      data:
        ${netbird_setup_key_secret_key}: "{{ .NB_SETUP_KEY  | toString }}"

  data:
    - secretKey: NB_SETUP_KEY
      remoteRef:
        key: ${netbird_setup_key_vault_path}
        property: value
---
apiVersion: netbird.io/v1
kind: NBSetupKey
metadata:
  name: ${netbird_setup_key_name}
  namespace: istio-system
spec:
  managementURL: ${netbird_management_url}
  secretKeyRef:
    name: ${netbird_setup_key_secret_name}
    key: ${netbird_setup_key_secret_key}