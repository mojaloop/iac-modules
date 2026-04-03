apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: report-object-storage-credentials
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: report-object-storage-credentials
    creationPolicy: Owner

  data:
    - secretKey: AWS_ACCESS_KEY_ID
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: "${cluster.env}/report_bucket_access_key_id"
        property: username
    - secretKey: AWS_SECRET_ACCESS_KEY
      remoteRef:
        conversionStrategy: Default
        decodingStrategy: None
        key: "${cluster.env}/report_bucket_access_key_id"
        property: password
---
# %{ if cloud_platform == "private-cloud" }
apiVersion: utils.mojaloop.io/v1alpha1
kind: ObjectSyncer
metadata:
  name: object-storage-ca
spec:
  parameters:
    objectType: Secret
    source:
      namespace: rook-ceph
      name: selfsigned-ca-cert
    destination:
      namespace: ${mojaloop_namespace}
      name: object-storage-ca
      secretType: kubernetes.io/tls
  providerConfigsRef:
    sourceK8sProviderName: sc-kubernetes-provider
    destinationK8sProviderName: kubernetes-provider
  managementPolicies:
    - "*"
# %{ endif }
