db:
  user: ${db_user}
  passwordSecret: ${db_password_secret}
  passwordSecretKey: ${db_password_secret_key}
  host: ${db_host}
  port: ${db_port}
  schema: ${db_schema}
  dfspSeed: ${dfsp_seed}

api:
  image:
    name: ghcr.io/pm4ml/connection-manager-api
    version: v2.4.0
  url: https://${mcm_fqdn}
  extraTLS:
    rootCert:
      enabled: false
  certManager:
    enabled: true
    serverCertSecretName: ${server_cert_secret_name}
    serverCertSecretNamespace: ${server_cert_secret_namespace}
  switchFQDN: ${switch_domain}
  switchId: ${hub_name}
  keycloak:
    enabled: ${keycloak_config.enabled}
    baseUrl: ${keycloak_config.base_url}
    discoveryUrl: ${keycloak_config.discovery_url}
    adminClientId: ${keycloak_config.admin_client_id}
    adminClientSecret:
      secretName: ${dfsp_api_service_secret_name}
      secretKey: ${dfsp_api_service_secret_key}
    dfspsRealm: ${keycloak_config.dfsps_realm}
    autoCreateAccounts: ${keycloak_config.auto_create_accounts}
  auth:
    enable2fa: ${auth_config.two_fa_enabled}
    enabled: ${openid_config.enabled}
    allowInsecure: ${openid_config.allow_insecure}
    discoveryUrl: ${openid_config.discovery_url}
    clientId: ${openid_config.client_id}
    clientSecret:
      secretName: ${dfsp_auth_client_secret_name}
      secretKey: ${dfsp_auth_client_secret_key}
    redirectUri: ${openid_config.redirect_uri}
    jwtCookieName: ${openid_config.jwt_cookie_name}
    everyoneRole: ${openid_config.everyone_role}
    mtaRole: ${openid_config.mta_role}
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
    externallyManaged: true
    serviceAccountNameOverride: ${mcm_service_account_name}
  rbac:
    enabled: false
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/log-level: "info"
    vault.hashicorp.com/agent-image: ghcr.io/mojaloop/vault-agent-util:0.0.2
    vault.hashicorp.com/agent-configmap: "vault-agent"
    vault.hashicorp.com/agent-pre-populate: "true"
    vault.hashicorp.com/agent-limits-mem: "128Mi"
    vault.hashicorp.com/agent-requests-mem: "64Mi"
    vault.hashicorp.com/agent-limits-cpu: "200m"
    vault.hashicorp.com/agent-requests-cpu: "100m"
    proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
ui:
  checkSessionUrl: https://${mcm_fqdn}/kratos/sessions/whoami
  loginUrl: https://${auth_fqdn}/kratos/self-service/login/browser
  loginProvider: keycloak
  logoutUrl: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_hubop_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
  oauth:
    enabled: true
    hubOidcProviderUrl: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect"
    clientId: ${oauth_key}
    clientSecretName: ${oauth_secret_secret}
    clientSecretKey: ${oauth_secret_secret_key}
  image:
    version: 1.8.4

ingress:
%{ if istio_create_ingress_gateways ~}
  enabled: false
%{ else ~}
  enabled: true
%{ endif ~}
  className: ${ingress_class}
  host: ${mcm_fqdn}
  tls:
    - hosts:
      - "*.${mcm_fqdn}"
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/whitelist-source-range: "${mcm_ingress_whitelist_source_range}"
migrations:
  enabled: true

config:
  caCSRParametersData: |-
    {
      "ST": "",
      "C": "",
      "L": "",
      "O": "${env_o}",
      "CN": "${env_cn}",
      "OU": "${env_ou}"
    }
