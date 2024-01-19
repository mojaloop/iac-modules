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
      path: ${keto_postgres_secret_path}/${keto_postgres_password_secret}
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
      path: ${kratos_postgres_secret_path}/${kratos_postgres_password_secret}
  output:
    name: ${kratos_dsn_secretname}
    stringData:
      dsn: 'postgresql://${kratos_postgres_user}:{{ .kratospaswordsecret.${kratos_postgres_password_secret_key} }}@tcp(${kratos_postgres_host}:${kratos_postgres_port})/${kratos_postgres_database}?max_conns=20&max_idle_conns=4'
    type: Opaque