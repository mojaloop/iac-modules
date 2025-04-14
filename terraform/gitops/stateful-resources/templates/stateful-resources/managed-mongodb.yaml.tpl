# This secret is specific to stateful_resources_namespace. Not of duplicate of definition in managed-crs.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${managed_stateful_resource.logical_service_config.user_password_secret}
  namespace: ${stateful_resources_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-11"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${managed_stateful_resource.logical_service_config.user_password_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner

  data:
    - secretKey: ${managed_stateful_resource.logical_service_config.user_password_secret_key}
      remoteRef:
        key: ${resource_password_vault_path}
        property: value