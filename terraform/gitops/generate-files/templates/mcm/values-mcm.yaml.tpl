db:
  user: ${db_user}
  passwordSecret: ${db_password_secret}
  passwordSecretKey: ${db_password_secret_key}
  host: ${db_host}
  port: ${db_port}
  schema: ${db_schema}
  dfspSeed: ${dfsp_seed}
  sslEnabled: true
  sslVerify: false
  sslCaSecret: ${db_tls_ca_secret_name}
  sslCaSecretKey: ${db_tls_ca_secret_key}

api:
  image:
    version: ${mcm_api_image_tag}
  replicaCount: ${mcm_api_replica_count}
  url: https://${mcm_fqdn}
  clientUrl: https://${mcm_fqdn}
  extraTLS:
    rootCert:
      enabled: false
  certManager:
    enabled: true
    serverCertSecretName: ${server_cert_secret_name}
    serverCertSecretNamespace: ${server_cert_secret_namespace}
  switchFQDN: ${switch_domain}
  switchId: ${hub_name}
  vault:
    auth:
      k8s:
        enabled: true
        token: /var/run/secrets/kubernetes.io/serviceaccount/token
        role: ${mcm_vault_k8s_role_name}
        mountPoint: ${k8s_auth_path}
    endpoint: ${vault_endpoint}
    mounts:
      pki: ${pki_path}
      kv: ${mcm_secret_path}
      dfspClientCertBundle: ${dfsp_client_cert_bundle}
      dfspInternalIPWhitelistBundle: ${dfsp_internal_whitelist_secret}
      dfspExternalIPWhitelistBundle: ${dfsp_external_whitelist_secret}
    pkiServerRole: ${pki_server_role}
    pkiClientRole: ${pki_client_role}
    signExpiryHours: 43800
  serviceAccount:
    name: ${mcm_service_account_name}
  rbac:
    enabled: false
  keycloak:
    enabled: true
    baseUrl: https://${keycloak_fqdn}
    discoveryUrl: https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/.well-known/openid-configuration
    adminClientId: connection-manager-api-service
    adminClientSecretName: ${mcm_dfsp_admin_client_secret}
    adminClientSecretKey: secret
    dfspsRealm: ${keycloak_dfsp_realm_name}
    autoCreateAccounts: true
  keto:
    enabled: true
    writeUrl: ${keto_write_url}
  openid:
    enabled: true
    clientId: ${dfsp_oidc_client_id}
    clientSecretName: ${dfsp_oidc_client_secret}
    clientSecretKey: secret
ui:
  checkSessionUrl: https://${mcm_fqdn}/kratos/sessions/whoami
  loginUrl: https://${auth_fqdn}/kratos/self-service/login/browser
  loginProvider: keycloak
  logoutUrl: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_dfsp_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
  oauth:
    enabled: true
    hubOidcProviderUrl: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect"

ingress:
  enabled: false

migrations:
  enabled: true
  script: migrate
  deletePolicy: ""

config:
  caCSRParametersData: |-
    {
      "ST": "",
      "C": "",
      "L": "",
      "O": "${hub_name}",
      "CN": "${switch_domain}",
      "OU": "${cluster_name}"
    }
