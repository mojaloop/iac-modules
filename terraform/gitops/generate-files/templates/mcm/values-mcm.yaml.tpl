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
  extraEnv:
    # Keycloak integration settings
    - name: KEYCLOAK_ENABLED
      value: "true"
    - name: KEYCLOAK_BASE_URL
      value: "https://${keycloak_fqdn}"
    - name: KEYCLOAK_DISCOVERY_URL
      value: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/.well-known/openid-configuration"
    - name: KEYCLOAK_ADMIN_CLIENT_ID
      value: "connection-manager-api-service"
    - name: KEYCLOAK_ADMIN_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: ${dfsp_api_service_secret_name}
          key: ${dfsp_api_service_secret_key}
    - name: KEYCLOAK_DFSPS_REALM
      value: "${keycloak_dfsp_realm_name}"
    - name: KEYCLOAK_AUTO_CREATE_ACCOUNTS
      value: "true"
    # 2FA Authentication settings
    - name: AUTH_2FA_ENABLED
      value: "${auth_2fa_enabled}"
    # OpenID settings
    - name: OPENID_ENABLED
      value: "${openid_enabled}"
    - name: OPENID_ALLOW_INSECURE
      value: "${openid_allow_insecure}"
    - name: OPENID_DISCOVERY_URL
      value: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/.well-known/openid-configuration"
    - name: OPENID_CLIENT_ID
      value: "connection-manager-auth-client"
    - name: OPENID_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: ${dfsp_auth_client_secret_name}
          key: ${dfsp_auth_client_secret_key}
    - name: OPENID_REDIRECT_URI
      value: "https://${mcm_fqdn}/api/auth/callback"
    # Cookie and role settings
    - name: OPENID_JWT_COOKIE_NAME
      value: "MCM-API_ACCESS_TOKEN"
    - name: OPENID_EVERYONE_ROLE
      value: "everyone"
    - name: OPENID_MTA_ROLE
      value: "dfsp-admin"
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
    vault.hashicorp.com/log-level: "debug"
    vault.hashicorp.com/agent-image: ghcr.io/mojaloop/vault-agent-util:0.0.2
    vault.hashicorp.com/agent-configmap: "vault-agent"
    vault.hashicorp.com/agent-pre-populate: "true"
    vault.hashicorp.com/agent-limits-mem: "" #this disables limit, TODO: need to tune this
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
    nginx.ingress.kubernetes.io/whitelist-source-range: "0.0.0.0/0"
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
