ingress:
  enabled: false

frontendRootUrl: &frontendRootUrl "https://${portal_fqdn}/"
frontendBaseUrl: &frontendBaseUrl "https://${experience_api_fqdn}/"

# this needs to have external URLs of both the UI and experience API
frontendRedirectUris: &frontendRedirectUris
  - "https://${portal_fqdn}/*"
  - "https://${experience_api_fqdn}/*"

# this _should_ be set to only allow requests from known origins
frontendWebOrigins: &frontendWebOrigins
  - "*"

# this should be set to the FSPID assigned by the mojaloop hub to this DFSP
dfspId: &dfspId "${dfsp_id}"

frontend:
  ingress:
    enabled: false
  env:
    API_BASE_URL: "https://${experience_api_fqdn}"
%{ if ory_stack_enabled ~}
    CHECK_SESSION_URL: https://${portal_fqdn}/kratos/sessions/whoami
    LOGIN_URL: https://${auth_fqdn}/kratos/self-service/login/browser
    LOGOUT_URL: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_pm4ml_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
    LOGIN_PROVIDER: ${keycloak_pm4ml_realm_name}
%{ endif ~}

experience-api:
  image:
    tag: 2.0.15-snapshot
  ingress:
    enabled: false
  env:
    enableMockData: false
    managementEndPoint: "${pm4ml_release_name}-management-api"
    dfspId: *dfspId
    appKeys: ootu1yoo5geeS7izai4ox1Yae1Eey6ai
    authClientId: "${pm4ml_oidc_client_id}"
    authClientSecretSecret: "${pm4ml_oidc_client_secret_secret}"
    authClientSecretSecretKey: "${vault_secret_key}"
    metricsEndPoint: "${pm4ml_release_name}-prometheus-server"
    authDiscoveryEndpoint: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/.well-known/openid-configuration"
    # this should be set to the external URL of the auth endpoint on the experience API
    authRedirectUri: "https://${experience_api_fqdn}/auth"
    # this should be set to the external URL of the UI
    authLoggedInLandingUrl: "https://${portal_fqdn}/"
    authSessionSecure: false

management-api:
  image:
    tag: 5.0.0-snapshot.2
  serviceAccountName: ${pm4ml_service_account_name}
  env:
    CACHE_URL: redis://${redis_host}:${redis_port}
    DFSP_ID: *dfspId
    HUB_IAM_PROVIDER_URL: "${pm4ml_external_switch_oidc_url}"
    OIDC_TOKEN_ROUTE: "${pm4ml_external_switch_oidc_token_route}"
    MCM_SERVER_ENDPOINT: "${mcm_host_url}/pm4mlapi"
    MCM_CLIENT_REFRESH_INTERVAL: 60
    PRIVATE_KEY_LENGTH: 2048
    PRIVATE_KEY_ALGORITHM: rsa
    AUTH_ENABLED: true
    AUTH_CLIENT_ID: ${pm4ml_external_switch_client_id}
    CLIENT_SECRET_NAME: ${pm4ml_external_switch_client_secret}
    CLIENT_SECRET_KEY: ${pm4ml_external_switch_client_secret_key}
    MCM_CLIENT_SECRETS_LOCATION: /tls
    VAULT_ENDPOINT: ${vault_endpoint}
    VAULT_AUTH_METHOD: K8S
    VAULT_K8S_ROLE: ${pm4ml_vault_k8s_role_name}
    VAULT_K8S_TOKEN_FILE: /var/run/secrets/kubernetes.io/serviceaccount/token
    VAULT_PKI_SERVER_ROLE: ${vault_pki_server_role}
    VAULT_PKI_CLIENT_ROLE: ${vault_pki_client_role}
    VAULT_MOUNT_PKI: ${vault_pki_mount}
    VAULT_MOUNT_KV: ${pm4ml_secret_path}/${pm4ml_release_name}
    MOJALOOP_CONNECTOR_FQDN: "${mojaloop_connnector_fqdn}"
    CALLBACK_URL: "${callback_url}"
    CERT_MANAGER_ENABLED: true
    CERT_MANAGER_SERVER_CERT_SECRET_NAME: ${server_cert_secret_name}
    CERT_MANAGER_SERVER_CERT_SECRET_NAMESPACE: ${server_cert_secret_namespace}
    WHITELIST_IP: "${nat_ip_list}"
  ingress:
    enabled: false

prometheus:
  server:
    persistentVolume:
      enabled: false
  alertmanager:
    persistentVolume:
      enabled: false
  pushgateway:
    persistentVolume:
      enabled: false
  extraScrapeConfigs: |-
    - job_name: 'prometheus-blackbox-exporter'
      static_configs:
        - targets:
          - "${pm4ml_release_name}-sdk-scheme-adapter-api-svc:4004"



scheme-adapter:
  sdk-scheme-adapter-api-svc:
    image:
%{ if fx_support_enabled ~}
      tag: v23.5.0-snapshot.0
%{ else ~}
      tag: v23.1.2-snapshot.2
%{ endif ~}
%{ if enable_sdk_bulk_transaction_support ~}
    kafka: &kafkaConfig
      host: ${kafka_host}
      port: ${kafka_port}
%{ endif ~}
    redis: &redisConfig
      host: ${redis_host}
      port: ${redis_port}
    config:
      simName: *dfspId
%{ if enable_sdk_bulk_transaction_support ~}
      bulkTransactionSupportEnabled: true
%{ else ~}
      bulkTransactionSupportEnabled: false
%{ endif ~}
      ## TODO: sdk chart is not accepting empty jws values if JWS params enabled. Need to fix.
      jwsSigningKey: "test"
      jwsVerificationKeys: {
        "test": "test"
      }
    env:
      DFSP_ID: *dfspId
      CACHE_URL: redis://${redis_host}:${redis_port}
      JWS_SIGN: true
      VALIDATE_INBOUND_JWS: true
      PEER_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      ALS_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      OUTBOUND_MUTUAL_TLS_ENABLED: true
      INBOUND_MUTUAL_TLS_ENABLED: false
      OAUTH_TOKEN_ENDPOINT: "${pm4ml_external_switch_oidc_url}/${pm4ml_external_switch_oidc_token_route}"
      OAUTH_CLIENT_KEY: "${pm4ml_external_switch_client_id}"
      OAUTH_CLIENT_SECRET_KEY: "${pm4ml_external_switch_client_secret_key}"
      OAUTH_CLIENT_SECRET_NAME: "${pm4ml_external_switch_client_secret}"
      RESERVE_NOTIFICATION: ${pm4ml_reserve_notification}
%{ if use_ttk_as_backend_simulator ~}
      BACKEND_ENDPOINT: "${pm4ml_release_name}-ttk-backend:4040"
%{ else ~}
      BACKEND_ENDPOINT: "${pm4ml_release_name}-mojaloop-core-connector:3003"
%{ endif ~}
      MGMT_API_WS_URL: "${pm4ml_release_name}-management-api"
%{ if fx_support_enabled ~}
      FX_QUOTES_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      FX_TRANSFERS_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      SUPPORTED_CURRENCIES: "${supported_currencies}"
      GET_SERVICES_FXP_RESPONSE: "${fxp_id}"
%{ endif ~}
%{ if enable_sdk_bulk_transaction_support ~}
      ENABLE_BACKEND_EVENT_HANDLER: true
      ENABLE_FSPIOP_EVENT_HANDLER: true
      REQUEST_PROCESSING_TIMEOUT_SECONDS: 30
%{ endif ~}

%{ if enable_sdk_bulk_transaction_support ~}
  sdk-scheme-adapter-dom-evt-handler:
    enabled: true
    kafka: *kafkaConfig
    redis: *redisConfig
    config:
      simName: *dfspId

  sdk-scheme-adapter-cmd-evt-handler:
    enabled: true
    kafka: *kafkaConfig
    redis: *redisConfig
    config:
      simName: *dfspId
%{ endif ~}
redis:
  replica:
    replicaCount: ${redis_replica_count}
  auth:
    enabled: false
    sentinel: false
  nameOverride: redis
  fullnameOverride: redis
  cluster:
    enabled: false
  master:
    persistence:
      enabled: true
    storageClass: ${storage_class_name}

ttk:
%{ if ttk_enabled ~}
  enabled: true
  ml-testing-toolkit-backend:
    image:
      repository: mojaloop/ml-testing-toolkit
      tag: v17.1.1
    ingress:
      enabled: false
    nameOverride: ttk-backend
    fullnameOverride: ttk-backend
    config_files:
      user_config.json: {
        "VERSION": 1,
        "CALLBACK_ENDPOINT": "http://${pm4ml_release_name}-sdk-scheme-adapter-api-svc:4001",
        "SEND_CALLBACK_ENABLE": true,
        "DEFAULT_ENVIRONMENT_FILE_NAME": "pm4ml-default-environment.json",
        "FSPID": *dfspId
      }

  ml-testing-toolkit-frontend:
    image:
      repository: mojaloop/ml-testing-toolkit-ui
      tag: v15.4.2
    ingress:
      enabled: false
    nameOverride: ttk-frontend
    fullnameOverride: ttk-frontend
    config:
      API_BASE_URL: https://${ttk_backend_fqdn}

%{ else ~}
  enabled: false
%{ endif ~}

keycloak:
  enabled: false
sim-backend:
  enabled: true
  env:
    OUTBOUND_ENDPOINT: http://${pm4ml_release_name}-mojaloop-connector:4001
    DFSP_ID: *dfspId
  ingress:
    enabled: false
testIngress:
  enabled: false
