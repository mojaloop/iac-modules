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
    name: tenant-vault-secret-store

  target:
    name: ${cert_manager_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${cert_manager_credentials_client_secret_name}
      remoteRef: 
        key: ${cert_manager_credentials_secret_provider_key}
        property: value
%{ if cert_manager_credentials_client_id_name != "" ~}
    - secretKey: ${cert_manager_credentials_client_id_name}
      remoteRef: 
        key: ${cert_manager_credentials_id_provider_key}
        property: value
%{ endif ~}