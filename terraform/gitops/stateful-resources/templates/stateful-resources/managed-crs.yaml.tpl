%{ for ns in password_map.namespaces ~}
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${password_map.secret_name}
  namespace: ${ns}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${password_map.secret_name} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${password_map.secret_key}
      remoteRef: 
        key: ${password_map.vault_path}
        property: value
%{ endfor ~}
