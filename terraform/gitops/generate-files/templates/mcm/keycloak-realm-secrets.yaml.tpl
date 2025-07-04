apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${keycloak_dfsp_realm_name}-realm-secrets
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
  secretKey: secret
  secretFormat:
    # Client secrets for Keycloak clients
    api-service-client-secret: "[a-zA-Z0-9]{32}"
    auth-client-secret: "[a-zA-Z0-9]{32}"

    # User passwords (16 chars with special characters)
    admin-password: "[a-zA-Z0-9@#$%^&*()_+=\\-]{16}"

    # Additional secrets for future use
    jwt-signing-secret: "[a-zA-Z0-9+/]{64}"
    encryption-key: "[a-fA-F0-9]{64}"
  secretType: Opaque
