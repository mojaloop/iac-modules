apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${role_assign_svc_secret}
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
      name: secret
      path: /secret/keycloak/${role_assign_svc_secret}
  output:
    name: ${role_assign_svc_secret}
    stringData:
      secret: '{{ .secret.${vault_secret_key} }}'
    type: Opaque