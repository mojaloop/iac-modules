apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: grafana-admin-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication: 
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: grafanaadmin
      path: /secret/grafana/grafana-admin
  output:
    name: grafana-admin-secret
    stringData:
      admin-user: grafana-admin
      admin-pw: '{{ .grafanaadmin.password }}'
    type: Opaque