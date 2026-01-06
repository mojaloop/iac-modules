apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${external_dns_credentials_secret}
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: ${external_dns_credentials_secret} # Name for the secret to be created on the cluster
    creationPolicy: Owner
%{ if dns_provider == "aws" ~}
    template:
      type: Opaque
      engineVersion: v2
      data:
        # multiline string
        credentials: |
          [default]
          aws_access_key_id = {{ .${external_dns_credentials_client_id_name} }}
          aws_secret_access_key = {{ .${external_dns_credentials_client_secret_name} }}
%{ endif ~}

  data:
    - secretKey: ${external_dns_credentials_client_secret_name}
      remoteRef:
        key: ${external_dns_credentials_secret_provider_key}
        property: value
%{ if external_dns_credentials_client_id_name != "" ~}
    - secretKey: ${external_dns_credentials_client_id_name}
      remoteRef:
        key: ${external_dns_credentials_id_provider_key}
        property: value
%{ endif ~}