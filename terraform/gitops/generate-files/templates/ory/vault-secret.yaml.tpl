apiVersion: redhatcop.redhat.io/v1alpha1
kind: PasswordPolicy
metadata:
  name: "kratos-secret-policy"
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
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
    argocd.argoproj.io/sync-wave: "-4"
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
    argocd.argoproj.io/sync-wave: "-4"
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
    argocd.argoproj.io/sync-wave: "-4"
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
%{ if kratos_mysql_deploy_type == "helm-chart" || kratos_mysql_deploy_type == "operator" ~}    
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: kratos-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: kratospaswordsecret
      path: ${kratos_mysql_secret_path}
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
      dsn: 'mysql://${kratos_mysql_user}:{{ .kratospaswordsecret.${kratos_mysql_password_secret_key} }}@tcp(${kratos_mysql_host}:${kratos_mysql_port})/${kratos_mysql_database}?max_conns=20&max_idle_conns=4'
      smtpConnectionURI: "smtps://test:test@mailslurper:1025/?skip_ssl_verify=true"
      secretsDefault: "{{ .kratosdefaultsecret.secret }}"
      secretsCookie: "{{ .kratoscookiesecret.secret }}"
      secretsCipher: "{{ .kratosciphersecret.secret }}"
      secretsCSRFCookie: "{{ .kratoscookiesecret.secret }}"
    type: Opaque
%{ else }
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: kratos-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
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
    name: kratos-secret-intermediate
    stringData:
      smtpConnectionURI: "smtps://test:test@mailslurper:1025/?skip_ssl_verify=true"
      secretsDefault: "{{ .kratosdefaultsecret.secret }}"
      secretsCookie: "{{ .kratoscookiesecret.secret }}"
      secretsCipher: "{{ .kratosciphersecret.secret }}"
      secretsCSRFCookie: "{{ .kratoscookiesecret.secret }}"
    type: Opaque
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${kratos_mysql_password_secret}-final
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: SecretStore
    name: ory-k8s-secret-store
  data:
    - secretKey: kratosDBManagedPasswordKey
      remoteRef:
        key: ${kratos_mysql_password_secret}
        property: ${kratos_mysql_password_secret_key}
    - secretKey: smtpConnectionURI
      remoteRef:
        key: kratos-secret-intermediate
        property: smtpConnectionURI      
    - secretKey: secretsDefault
      remoteRef:
        key: kratos-secret-intermediate
        property: secretsDefault   
    - secretKey: secretsCookie
      remoteRef:
        key: kratos-secret-intermediate
        property: secretsCookie   
    - secretKey: secretsCipher
      remoteRef:
        key: kratos-secret-intermediate
        property: secretsCipher   
    - secretKey: secretsCSRFCookie
      remoteRef:
        key: kratos-secret-intermediate
        property: secretsCSRFCookie  

  target:
    name: kratos-secret
    creationPolicy: Owner
    template:
      data:
        dsn: 'mysql://${kratos_mysql_user}:{{ .kratosDBManagedPasswordKey }}@tcp(${kratos_mysql_host}:${kratos_mysql_port})/${kratos_mysql_database}?max_conns=20&max_idle_conns=4&sql_mode=TRADITIONAL'
        smtpConnectionURI: "{{ .smtpConnectionURI }}"
        secretsDefault: "{{ .secretsDefault }}"
        secretsCookie: "{{ .secretsCookie }}"
        secretsCipher: "{{ .secretsCipher }}"
        secretsCSRFCookie: "{{ .secretsCSRFCookie }}"
%{ endif }
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

%{ if keto_mysql_deploy_type == "external" || kratos_mysql_deploy_type == "external" }
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ory-secret-creator
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"    
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${ory_namespace}
  name: ory-secret-role
  annotations:
    argocd.argoproj.io/sync-wave: "-4"    
rules:
  - apiGroups: [""]
    resources:
      - secrets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - authorization.k8s.io
    resources:
      - selfsubjectrulesreviews
    verbs:
      - create
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ory-secret-creator
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"    
subjects:
  - kind: ServiceAccount
    name: ory-secret-creator
roleRef:
  kind: Role
  name: ory-secret-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: ory-k8s-secret-store
  namespace: ${ory_namespace}
  annotations:
    argocd.argoproj.io/sync-wave: "-4"    
spec:
  provider:
    kubernetes:
      auth:
        serviceAccount:
          name: "ory-secret-creator"
      remoteNamespace: ${ory_namespace}
      server:
        caProvider:
          type: ConfigMap
          name: kube-root-ca.crt
          key: ca.crt
%{ endif }
%{ if keto_mysql_deploy_type == "helm-chart" || keto_mysql_deploy_type == "operator" ~}
---
apiVersion: redhatcop.redhat.io/v1alpha1
kind: VaultSecret
metadata:
  name: keto-secret
  annotations:
    argocd.argoproj.io/sync-wave: "-4"
spec:
  refreshPeriod: 1m0s
  vaultSecretDefinitions:
    - authentication:
        path: kubernetes
        role: policy-admin
        serviceAccount:
            name: default
      name: ketopasswordsecret
      path: ${keto_mysql_secret_path}
  output:
    name: keto-secret
    stringData:
      dsn: 'mysql://${keto_mysql_user}:{{ .ketopasswordsecret.${keto_mysql_password_secret_key} }}@tcp(${keto_mysql_host}:${keto_mysql_port})/${keto_mysql_database}?max_conns=20&max_idle_conns=4'
    type: Opaque
%{ else }
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${keto_mysql_password_secret}-final
  annotations:
    argocd.argoproj.io/sync-wave: "-3"
spec:
  refreshInterval: 5m

  secretStoreRef:
    kind: SecretStore
    name: ory-k8s-secret-store
  data:
    - secretKey: ketoDBManagedPasswordKey
      remoteRef:
        key: ${keto_mysql_password_secret}
        property: ${keto_mysql_password_secret_key}

  target:
    name: keto-secret
    creationPolicy: Owner
    template:
      data:
        dsn: 'mysql://${keto_mysql_user}:{{ .ketoDBManagedPasswordKey }}@tcp(${keto_mysql_host}:${keto_mysql_port})/${keto_mysql_database}?max_conns=20&max_idle_conns=4' 

%{ endif }
