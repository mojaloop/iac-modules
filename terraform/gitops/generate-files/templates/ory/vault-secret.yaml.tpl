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
      secretsCSRFCookie: "{{ .kratoscookiesecret.secret }}"
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
      path: ${hubop_oidc_client_secret_secret_path}/${hubop_oidc_client_secret_secret}
# %{ for provider in oidc_providers }
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: ${replace(provider.realm, "-", "_")}
      path: ${hubop_oidc_client_secret_secret_path}/${provider.secret_name}
# %{ endfor }
  output:
    name: kratos-oidc-providers
    stringData:
      value: '[
          {
            "id":"keycloak",
            "provider":"generic",
            "client_id":"${hubop_oidc_client_id}",
            "client_secret":"{{ .kratosoidcsecret.${vault_secret_key} }}",
            "scope":["openid", "profile", "email"],
            "mapper_url":"base64://bG9jYWwgY2xhaW1zID0gc3RkLmV4dFZhcignY2xhaW1zJyk7Cgp7CiAgaWRlbnRpdHk6IHsKICAgIHRyYWl0czogewogICAgICBlbWFpbDogY2xhaW1zLmVtYWlsLAogICAgICBuYW1lOiBjbGFpbXMuZW1haWwsCiAgICAgIHN1YmplY3Q6IGNsYWltcy5zdWIKICAgIH0sCiAgfSwKfQ==",
            "issuer_url":"https://${keycloak_fqdn}/realms/${keycloak_hubop_realm_name}"
          }
          %{ for provider in oidc_providers ~}
          ,{
            "id":"${provider.realm}",
            "provider":"generic",
            "client_id":"${provider.client_id}",
            "client_secret":"{{ .${replace(provider.realm, "-", "_")}.${vault_secret_key} }}",
            "scope":["openid", "profile", "email"],
            "mapper_url":"base64://bG9jYWwgY2xhaW1zID0gc3RkLmV4dFZhcignY2xhaW1zJyk7Cgp7CiAgaWRlbnRpdHk6IHsKICAgIHRyYWl0czogewogICAgICBlbWFpbDogY2xhaW1zLmVtYWlsLAogICAgICBuYW1lOiBjbGFpbXMuZW1haWwsCiAgICAgIHN1YmplY3Q6IGNsYWltcy5zdWIKICAgIH0sCiAgfSwKfQ==",
            "issuer_url":"https://${keycloak_fqdn}/realms/${provider.realm}"
          }
          %{ endfor ~}
        ]'
    type: Opaque
