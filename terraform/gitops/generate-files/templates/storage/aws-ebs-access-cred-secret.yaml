apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: ${access_secret_name}
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${access_secret_name}
    creationPolicy: Owner
    template:
      data:
        access_key_id: "{{ .AWS_SECRET_ACCESS_KEY  | toString }}"
        secret_access_key: "{{ .AWS_ACCESS_KEY_ID  | toString }}"

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # TODO: max provider agnostic
      remoteRef: 
        key: ${access_key_id}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef: 
        key: ${secret_access_key}
        property: value