apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: "kratos-secret-policy"
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
    charset = "0123456789"
    min-chars = 1
    }
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: kratos-cookie
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/generated/kratos/
  secretKey: secret
  secretFormat:
    passwordPolicyName: "kratos-secret-policy"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: kratos-cipher
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/generated/kratos/
  secretKey: secret
  secretFormat:
    passwordPolicyName: "kratos-secret-policy"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: RandomSecret
metadata:
  name: kratos-default
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  authentication:
    path: kubernetes
    role: policy-admin
    serviceAccount:
      name: default
  isKVSecretsEngineV2: false
  path: /secret/generated/kratos/
  secretKey: secret
  secretFormat:
    passwordPolicyName: "kratos-secret-policy"
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: keto-secret
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
      name: ketopasswordsecret
      path: ${keto_postgres_secret_path}
  output:
    name: keto-secret
    stringData:
      dsn: 'postgresql://${keto_postgres_user}:{{ .ketopasswordsecret.${keto_postgres_password_secret_key} }}@${keto_postgres_host}:${keto_postgres_port}/${keto_postgres_database}?max_conns=20&max_idle_conns=4'
    type: Opaque
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: kratos-secret
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
      name: kratospaswordsecret
      path: ${kratos_postgres_secret_path}
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: kratosdefaultsecret
      path: /secret/generated/kratos/kratos-default
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: kratoscookiesecret
      path: /secret/generated/kratos/kratos-cookie
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
          name: default
      name: kratosciphersecret
      path: /secret/generated/kratos/kratos-cipher
  output:
    name: kratos-secret
    stringData:
      dsn: 'postgresql://${kratos_postgres_user}:{{ .kratospaswordsecret.${kratos_postgres_password_secret_key} }}@${kratos_postgres_host}:${kratos_postgres_port}/${kratos_postgres_database}?max_conns=20&max_idle_conns=4'
      smtpConnectionURI: "smtps://test:test@mailslurper:1025/?skip_ssl_verify=true"
      secretsDefault: "{{ .kratosdefaultsecret.secret }}"
      secretsCookie: "{{ .kratoscookiesecret.secret }}"
      secretsCipher: "{{ .kratosciphersecret.secret }}"
    type: Opaque
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: kratos-oidc-providers
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
      name: kratosoidcsecret
      path: ${kratos_oidc_client_secret_secret_path}/${kratos_oidc_client_secret_secret_name}
  output:
    name: kratos-oidc-providers
    stringData:
      value: '[{"id":"idp","provider":"generic","client_id":"${kratos_oidc_client_id}","client_secret":"{{ .kratosoidcsecret.${kratos_oidc_client_secret_secret_key} }}","scope":["openid", "profile", "email"],"mapper_url":"file:///etc/config/kratos/oidc.keycloak.jsonnet","issuer_url":"https://${keycloak_fqdn}/realms/${keycloak_kratos_realm_name}"}]'
    type: Opaque