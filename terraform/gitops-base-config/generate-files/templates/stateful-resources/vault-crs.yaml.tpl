%{ if resource.generate_secret_name != null ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${resource.resource_type}-${resource.resource_name}-policy
  namespace: ${resource.resource_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
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
        charset = "!@#$%^&*"
        min-chars = 1
      }
---
%{ for key in resource.generate_secret_keys ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${resource.generate_secret_name}-${key}
  namespace: ${resource.resource_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${resource.generate_secret_vault_base_path}/${resource.resource_name}
  secretKey: ${key}
  secretFormat:
    passwordPolicyName: ${resource.resource_type}-${resource.resource_name}-policy
---
%{ endfor ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${resource.generate_secret_name}
  namespace: ${resource.resource_namespace}
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
      name: dynamicsecret
      path: ${resource.generate_secret_vault_base_path}/${resource.resource_name}
  output:
    name: ${resource.generate_secret_name}
    stringData:
%{ for key in resource.generate_secret_keys ~}
      ${key}: '{{ .dynamicsecret.${key} }}'
%{ endfor ~}
    type: Opaque
%{ endif ~}