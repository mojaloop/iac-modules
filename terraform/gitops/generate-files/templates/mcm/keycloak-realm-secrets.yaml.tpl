# Password Policy for Client Secrets (32 chars, alphanumeric)
apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: ${keycloak_dfsp_realm_name}-client-secret-policy
  namespace: ${keycloak_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-5"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  passwordPolicy: |
    length = 32
    rule "charset" {
      charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      min-chars = 32
    }
---
# API Service Client Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${keycloak_dfsp_realm_name}-api-service-client-secret
  namespace: ${keycloak_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/keycloak/${keycloak_dfsp_realm_name}-realm-secrets
  secretKey: password
  secretFormat:
    passwordPolicyName: ${keycloak_dfsp_realm_name}-client-secret-policy
---
# Auth Client Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${keycloak_dfsp_realm_name}-auth-client-secret
  namespace: ${keycloak_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/keycloak/${keycloak_dfsp_realm_name}-realm-secrets
  secretKey: password
  secretFormat:
    passwordPolicyName: ${keycloak_dfsp_realm_name}-client-secret-policy
