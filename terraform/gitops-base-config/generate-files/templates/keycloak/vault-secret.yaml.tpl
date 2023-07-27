apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: "jwt-secret"
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
    length = 32
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
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: jwt-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication: 
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/keycloak/
  secretKey: secret
  secretFormat:
    passwordPolicyName: "jwt-secret"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: keycloak-dfsps-realm-jwt-secret
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
      name: keycloakjwtsecret
      path: /secret/keycloak/jwt-secret
  output:
    name: keycloak-dfsps-realm-jwt-secret
    stringData:
      secret: '{{ .keycloakjwtsecret.secret }}'
    type: Opaque