apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${object_store_velero_credentials_secret_name}
  namespace: ${velero_namespace}
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  data:
    - secretKey: username
      remoteRef:
        key: ${object_store_velero_user_key}
        property: username
    - secretKey: password
      remoteRef:
        key: ${object_store_velero_password_key}
        property: password

  target:
    name:  ${object_store_velero_credentials_secret_name}
    creationPolicy: Owner
    template:
      data:
        AWS_SECRET_ACCESS_KEY: "{{ .password }}"
        AWS_ACCESS_KEY_ID: "{{ .username }}"
        AWS_REGION: ${object_store_region}
        ${object_store_velero_secret_key}: |
          [default]
          aws_access_key_id = {{ .username | toString }}
          aws_secret_access_key = {{ .password  | toString }}
