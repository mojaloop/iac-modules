apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${key}-password-policy
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  # Add fields here
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  passwordPolicy: |
    length = 20
      rule "charset" {
        charset = "abcdefghijklmnopqrstuvwxyz"
        min-chars = 1
      }
      rule "charset" {
        charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        min-chars = 1
      }
      rule "charset" {
        charset = "0123456789"
        min-chars = 1
      }
      rule "charset" {
        charset = "_"
        min-chars = 1
      }
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${secret_name}
  namespace: ${namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  path: /secret/generated/${key}
  secretKey: password
  secretFormat:
    passwordPolicyName: ${key}-password-policy
---
%{ for ns in concat([namespace], extra_namespaces) ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${secret_name}
  namespace: ${ns}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: dynamicsecret_db_password
      path: /secret/generated/${key}/${secret_name}
  output:
    name: ${secret_name}
    stringData:
      ${secret_key}: "{{ .dynamicsecret_db_password.password }}"
    type: Opaque
---
%{ endfor ~}