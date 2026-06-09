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
  ### Configure this if you want to pass a CA certificate of the server.
  sslCaSecret: ${db_tls_ca_secret_name}
  sslCaSecretKey: ${db_tls_ca_secret_key}

api:
  image:
    name: mojaloop/connection-manager-api
    version: v3.7.1
  replicaCount: ${mcm_api_replica_count}
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
    name: ${mcm_service_account_name}
  rbac:
    enabled: false
  annotations:
    proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
ui:
  checkSessionUrl: https://${mcm_fqdn}/kratos/sessions/whoami
  loginUrl: https://${auth_fqdn}/kratos/self-service/login/browser
  loginProvider: keycloak
  logoutUrl: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_hubop_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
  oauth:
    enabled: false # The authentication flow is handled by Kratos
    hubOidcProviderUrl: "https://${keycloak_fqdn}/realms/${keycloak_hubop_realm_name}/protocol/openid-connect"
    # The following are not used when Kratos is handling authentication
    # clientId: ${oauth_key}
    # clientSecretName: ${oauth_secret_secret}
    # clientSecretKey: ${oauth_secret_secret_key}
  image:
    name: mojaloop/connection-manager-ui
    version: v1.11.0

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
  script: ${mcm_migration_script}
  deletePolicy: ""

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
