apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: kubernetes-provider
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
spec:
  credentials:
    source: InjectedIdentity
%{ if cloud_provider == "private-cloud" ~}
---
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: sc-kubernetes-provider
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: ${crossplane_namespace}
      name: sc-k8s-kubeconfig
      key: kubeconfig

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "${external_secret_sync_wave}"
  name: sc-k8s-kubeconfig
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: tenant-vault-secret-store

  data:
    - secretKey: sc_api_server
      remoteRef:
        key: ${sc_api_server}
        property: sc-api-server
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: sc_api_ca
      remoteRef:
        key: ${sc_api_ca}
        property: sc-api-ca
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
    - secretKey: sc_api_token
      remoteRef:
        key: ${sc_api_token}
        property: token
      sourceRef:
        storeRef:
          name: tenant-vault-secret-store
          kind: ClusterSecretStore
  target:
    name: sc-k8s-kubeconfig
    creationPolicy: Owner
    template:
      data:
        kubeconfig: |
          apiVersion: v1
          kind: Config
          clusters:
          - name: sc-cluster
            cluster:
              server: {{.sc_api_server}}
              certificate-authority-data: {{.sc_api_ca}}
          users:
          - name: sc-k8s-user
            user:
              token: {{.sc_api_token}}
          contexts:
          - name: sc-k8s-cluster
            context:
              cluster: sc-cluster
              namespace: ${cluster_name}
              user: sc-k8s-user
          current-context: sc-k8s-cluster
%{ endif ~}