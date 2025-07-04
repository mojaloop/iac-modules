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
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-family-aws
  annotations:
    argocd.argoproj.io/sync-wave: 5
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-family-aws:v${crossplane_providers_aws_family_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-iam
  annotations:
    argocd.argoproj.io/sync-wave: 10
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-aws-iam:v${crossplane_providers_aws_iam_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-docdb
  annotations:
    argocd.argoproj.io/sync-wave: 10
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-aws-docdb:v${crossplane_providers_aws_docdb_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-ec2
  annotations:
    argocd.argoproj.io/sync-wave: 10
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-aws-ec2:v${crossplane_providers_aws_ec2_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-rds
  annotations:
    argocd.argoproj.io/sync-wave: 10
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-aws-rds:v${crossplane_providers_aws_rds_version}
  skipDependencyResolution: true
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-route53
  annotations:
    argocd.argoproj.io/sync-wave: 10
spec:
  package: ghcr.io/mojaloop/infra/upbound/provider-aws-route53:v${crossplane_providers_aws_route53_version}
  skipDependencyResolution: true
