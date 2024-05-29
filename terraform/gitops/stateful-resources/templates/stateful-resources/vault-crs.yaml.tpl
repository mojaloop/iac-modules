%{ if secret_config.generate_secret_name != null ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${resource.resource_type}-${key}-policy
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
        charset = "${try(secret_config.generate_secret_special_chars, "!@#$%^&*")}"
        min-chars = 1
      }
---
%{ for secretKey in secret_config.generate_secret_keys ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${secret_config.generate_secret_name}-${secretKey}
  namespace: ${namespace} 
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${secret_config.generate_secret_vault_base_path}/${key}
  secretKey: password
  secretFormat:
    passwordPolicyName: ${resource.resource_type}-${key}-policy
---
%{ endfor ~}
%{ for ns in concat([namespace], secret_config.generate_secret_extra_namespaces) ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${secret_config.generate_secret_name}
  namespace: ${ns}
  annotations:
    argocd.argoproj.io/sync-wave: "-6"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
%{ for secretKey in secret_config.generate_secret_keys ~}
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: dynamicsecret_${replace(secretKey, "-", "_")}
      path: ${secret_config.generate_secret_vault_base_path}/${key}/${secret_config.generate_secret_name}-${secretKey}
%{ endfor ~}
  output:
    name: ${secret_config.generate_secret_name}
    stringData:
%{ for secretKey in secret_config.generate_secret_keys ~}
      ${secretKey}: '{{ .dynamicsecret_${replace(secretKey, "-", "_")}.password }}'
%{ endfor ~}
    type: Opaque
---
%{ endfor ~}
%{ endif ~}