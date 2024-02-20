db:
  user: ${db_user}
  passwordSecret: ${db_password_secret}
  passwordSecretKey: ${db_password_secret_key}
  host: ${db_host}
  port: ${db_port}
  schema: ${db_schema}

api:
  image:
    name: ghcr.io/pm4ml/connection-manager-api
    version: v1.9.7-snapshot.5
  url: https://${mcm_public_fqdn}
  extraTLS:
    rootCert:
      enabled: false
  wso2TokenIssuer:
    cert:
      enabled: false
  oauth:
    enabled: false
    issuer: https://${token_issuer_fqdn}/oauth2/token
    key: ${oauth_key}
    clientSecretSecret: ${oauth_secret_secret}
    clientSecretSecretKey: ${oauth_secret_secret_key}
  auth2fa:
    enabled: false
  totp:
    label: MCM
    issuer: ${totp_issuer}
  certManager:
    enabled: true
    serverCertSecretName: ${server_cert_secret_name}
    serverCertSecretNamespace: ${server_cert_secret_namespace}
  switchFQDN: ${switch_domain}
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
# %{ if ory_stack_enabled ~}
  checkSessionUrl: https://${mcm_public_fqdn}/kratos/sessions/whoami
  loginUrl: https://${auth_fqdn}/kratos/self-service/login/browser
  loginProvider: keycloak
# %{ endif ~}
  oauth:
# %{ if ory_stack_enabled ~}
    enabled: true
# %{ else ~}
    enabled: false
# %{ endif ~}
    hubOidcProviderUrl: "https://${keycloak_fqdn}/realms/${keycloak_dfsp_realm_name}/protocol/openid-connect"
    clientId: ${oauth_key}
    clientSecretName: ${oauth_secret_secret}
    clientSecretKey: ${oauth_secret_secret_key}

ingress:
# %{ if istio_create_ingress_gateways ~}
  enabled: false
# %{ else ~}
  enabled: true
# %{ endif ~}
  className: ${ingress_class}
  host: ${mcm_public_fqdn}
  tls:
    - hosts:
      - "*.${mcm_public_fqdn}"
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