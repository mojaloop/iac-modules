%{ if resource.local_helm_config.generate_secret_name != null ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${resource.resource_type}-${key}-policy
  namespace: ${resource.local_helm_config.resource_namespace}
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
        charset = "${try(resource.local_helm_config.generate_secret_special_chars, "!@#$%^&*")}"
        min-chars = 1
      }
---
%{ for secretKey in resource.local_helm_config.generate_secret_keys ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${resource.local_helm_config.generate_secret_name}-${secretKey}
  namespace: ${resource.local_helm_config.resource_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${resource.local_helm_config.generate_secret_vault_base_path}/${key}
  secretKey: password
  secretFormat:
    passwordPolicyName: ${resource.resource_type}-${key}-policy
---
%{ endfor ~}
%{ for ns in concat([resource.local_helm_config.resource_namespace], resource.local_helm_config.generate_secret_extra_namespaces) ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${resource.local_helm_config.generate_secret_name}
  namespace: ${ns}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
%{ for secretKey in resource.local_helm_config.generate_secret_keys ~}
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: dynamicsecret_${replace(secretKey, "-", "_")}
      path: ${resource.local_helm_config.generate_secret_vault_base_path}/${key}/${resource.local_helm_config.generate_secret_name}-${key}
%{ endfor ~}
  output:
    name: ${resource.local_helm_config.generate_secret_name}
    stringData:
%{ for secretKey in resource.local_helm_config.generate_secret_keys ~}
      ${secretKey}: '{{ .dynamicsecret_${replace(secretKey, "-", "_")}.password }}'
%{ endfor ~}
    type: Opaque
---
%{ endfor ~}
%{ endif ~}