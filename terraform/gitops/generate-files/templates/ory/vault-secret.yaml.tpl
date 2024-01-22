apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${keto_dsn_secretname}
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
    name: ${keto_dsn_secretname}
    stringData:
      dsn: 'postgresql://${keto_postgres_user}:{{ .ketopasswordsecret.${keto_postgres_password_secret_key} }}@tcp(${keto_postgres_host}:${keto_postgres_port})/${keto_postgres_database}?max_conns=20&max_idle_conns=4'
    type: Opaque
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: ${kratos_dsn_secretname}
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
  output:
    name: ${kratos_dsn_secretname}
    stringData:
      dsn: 'postgresql://${kratos_postgres_user}:{{ .kratospaswordsecret.${kratos_postgres_password_secret_key} }}@tcp(${kratos_postgres_host}:${kratos_postgres_port})/${kratos_postgres_database}?max_conns=20&max_idle_conns=4'
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
      value: '[{"id":"idp","provider":"generic","client_id":"${kratos_oidc_client_id}","client_secret":"{{ .kratosoidcsecret.${kratos_oidc_client_secret_secret_key} }}","scope":["openid"],"mapper_url":"base64://bG9jYWwgY2xhaW1zID0gc3RkLmV4dFZhcignY2xhaW1zJyk7Cgp7CiAgaWRlbnRpdHk6IHsKICAgIHRyYWl0czogewogICAgICBlbWFpbDogY2xhaW1zLmVtYWlsLAogICAgICBuYW1lOiBjbGFpbXMuZW1haWwsCiAgICAgIHN1YmplY3Q6IGNsYWltcy5zdWIKICAgIH0sCiAgfSwKfQ==","issuer_url":"${keycloak_fqdn}/oauth2/token"}]'
    type: Opaque