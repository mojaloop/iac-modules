apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: secret-aws-xplane-backend-creds
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: secret-aws-xplane-backend-creds # Name for the secret to be created on the cluster
    creationPolicy: Owner
    template:
      type: Opaque
      engineVersion: v2
      data:
        # multiline string
        creds: |
          [default]
          aws_access_key_id = {{ .AWS_ACCESS_KEY_ID }}
          aws_secret_access_key = {{ .AWS_SECRET_ACCESS_KEY }}

  data:
    - secretKey: AWS_SECRET_ACCESS_KEY # TODO: max provider agnostic
      remoteRef:
        key: ${cloud_credentials_secret_provider_key}
        property: value
    - secretKey: AWS_ACCESS_KEY_ID # Key given to the secret to be created on the cluster
      remoteRef:
        key: ${cloud_credentials_id_provider_key}
        property: value
---
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: aws-cp-upbound-provider-config
spec:
  credentials:
    source: Secret
    secretRef:
      key: creds
      name: secret-aws-xplane-backend-creds
      namespace: ${crossplane_namespace}