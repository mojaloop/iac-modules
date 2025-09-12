apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: argo-oidc
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  target:
    name: argo-oidc
    creationPolicy: Owner
    template:
      metadata:
        labels:
          app.kubernetes.io/part-of: argocd
  data:
    - secretKey: clientid
      remoteRef: 
        key: {{ cluster_name }}/argocd_oidc_client_id
        property: value
    - secretKey: clientsecret
      remoteRef: 
        key: {{ cluster_name }}/argocd_oidc_client_secret
        property: value