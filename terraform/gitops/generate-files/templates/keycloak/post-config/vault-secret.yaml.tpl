apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: "keycloak-client-secret"
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
%{ for ref_secret_name, ref_secret_key in ref_secrets ~}
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: ${ref_secret_name}
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: ${ref_secrets_path}/
  secretKey: secret
  secretFormat:
    passwordPolicyName: "keycloak-client-secret"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${ref_secret_name}
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
      name: keycloaksecret
      path: ${ref_secrets_path}/${ref_secret_name}
  output:
    name: ${ref_secret_name}
    stringData:
      secret: '{{ .keycloaksecret.${ref_secret_key} }}'
    type: Opaque
---
%{ endfor ~}
%{ if smtp_auth ~}
# SMTP User Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: smtp-credentials-user
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
      name: smtpcreds
      path: /secret/smtp-credentials
  output:
    name: smtp-credentials-user
    stringData:
      secret: '{{ .smtpcreds.smtp_user }}'
    type: Opaque
---
# SMTP Password Secret
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: smtp-credentials-password
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
      name: smtpcreds
      path: /secret/smtp-credentials
  output:
    name: smtp-credentials-password
    stringData:
      secret: '{{ .smtpcreds.smtp_password }}'
    type: Opaque
---
%{ endif ~}
