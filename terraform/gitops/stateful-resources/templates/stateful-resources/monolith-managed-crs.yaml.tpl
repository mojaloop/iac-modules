apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${secret_name}
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${secret_key}
      remoteRef: 
        key: ${vault_path}
        property: value
