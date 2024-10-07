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
    CHECK_SESSION_URL: https://${portal_fqdn}/kratos/sessions/whoami
    LOGIN_URL: https://${auth_fqdn}/kratos/self-service/login/browser
    LOGOUT_URL: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_pm4ml_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
    LOGIN_PROVIDER: ${keycloak_pm4ml_realm_name}

experience-api:
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
    cacheUrl: redis://${redis_host}:${redis_port}

mojaloop-core-connector:
  ${indent(2, yamlencode(core_connector_config))}

mojaloop-payment-token-adapter:
  ${indent(2, yamlencode(payment_token_adapter_config))}

management-api:
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
#%{ if enable_sdk_bulk_transaction_support}
    kafka: &kafkaConfig
      host: ${kafka_host}
      port: ${kafka_port}
#%{ endif}
    redis: &redisConfig
      host: ${redis_host}
      port: ${redis_port}
    config:
      simName: *dfspId
#%{ if enable_sdk_bulk_transaction_support}
      bulkTransactionSupportEnabled: true
#%{ else}
      bulkTransactionSupportEnabled: false
#%{ endif}
      ## TODO: sdk chart is not accepting empty jws values if JWS params enabled. Need to fix.
      jwsSigningKey: "test"
      jwsVerificationKeys: {
        "test": "test"
      }
    env:
      LOG_LEVEL: error
      DFSP_ID: *dfspId
      CACHE_URL: redis://${redis_host}:${redis_port}
      AUTO_ACCEPT_QUOTES: false
      AUTO_ACCEPT_PARTY: ${auto_accept_party}
      AUTO_ACCEPT_R2P_PARTY: false
      AUTO_ACCEPT_R2P_BUSINESS_QUOTES: false
      AUTO_ACCEPT_R2P_DEVICE_OTP: false
      AUTO_ACCEPT_PARTICIPANTS_PUT: false
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
#%{ if core_connector_selected == "ttk"}
      BACKEND_ENDPOINT: "${pm4ml_release_name}-ttk-backend:4040"
#%{ else}
#%{ if core_connector_selected == "cc"}
      BACKEND_ENDPOINT: "${pm4ml_release_name}-mojaloop-core-connector:3003"
#%{ else}
      BACKEND_ENDPOINT: "${custom_core_connector_endpoint}"
#%{ endif}
#%{ endif}
      MGMT_API_WS_URL: "${pm4ml_release_name}-management-api"
      FX_QUOTES_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      FX_TRANSFERS_ENDPOINT: "${pm4ml_external_switch_fqdn}"
      SUPPORTED_CURRENCIES: "${supported_currencies}"
      GET_SERVICES_FXP_RESPONSE: "${fxp_id}"
#%{ if enable_sdk_bulk_transaction_support}
      ENABLE_BACKEND_EVENT_HANDLER: true
      ENABLE_FSPIOP_EVENT_HANDLER: true
      REQUEST_PROCESSING_TIMEOUT_SECONDS: 30
#%{ else}
      REQUEST_PROCESSING_TIMEOUT_SECONDS: 10
#%{ endif}

#%{ if enable_sdk_bulk_transaction_support}
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
#%{ endif}
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
#%{ if ttk_enabled}
  enabled: true
  ml-testing-toolkit-backend:
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
        "GITHUB_CONFIG": {
          "TEST_CASES_REPO_OWNER": "mojaloop",
          "TEST_CASES_REPO_NAME": "testing-toolkit-test-cases",
          "TEST_CASES_REPO_DEFAULT_RELEASE_TAG": "${ttk_testcases_tag}",
          "TEST_CASES_REPO_BASE_PATH": "collections/pm4ml"
        },
        "DEFAULT_REQUEST_TIMEOUT": 15000,
        "FSPID": *dfspId
      }
      system_config.json:
        {
          "API_DEFINITIONS":
            [
              {
                "type": "mojaloop_connector_outbound",
                "version": "2.1",
                "folderPath": "mojaloop_connector_outbound_2.1",
                "asynchronous": false,
                "hostnames": [],
                "prefix": "/sdk-out",
              },
              {
                "type": "mojaloop_connector_backend",
                "version": "2.1",
                "folderPath": "mojaloop_connector_backend_2.1",
                "asynchronous": false,
              },
              {
                "type": "core_connector",
                "version": "1.4",
                "folderPath": "payment_manager_1.4",
                "hostnames": [],
                "prefix": "/cc-send",
              },
            ],
        }
      rules_response__default.json: https://raw.githubusercontent.com/mojaloop/testing-toolkit-test-cases/v16.1.0-fx-snapshot.1/rules/pm4ml/fxp_response_rules.json
      api_definitions__mojaloop_connector_backend_2.1__api_spec.yaml: "https://raw.githubusercontent.com/mojaloop/api-snippets/v17.4.0/docs/sdk-scheme-adapter-backend-v2_1_0-openapi3-snippets.yaml"
      api_definitions__mojaloop_connector_outbound_2.1__api_spec.yaml: "https://raw.githubusercontent.com/mojaloop/api-snippets/main/docs/sdk-scheme-adapter-outbound-v2_1_0-openapi3-snippets.yaml"
      api_definitions__mojaloop_connector_outbound_2.1__callback_map.json: []
    extraEnvironments:
      pm4ml-default-environment.json: {
        "inputValues": {
          "ENABLE_WS_ASSERTIONS": true,
          "WS_ASSERTION_TIMEOUT": 5000,
          "RETRY_MAX_ATTEMPTS": 100,
          "FROM_DISPLAY_NAME": "Display-Test",
          "FROM_FIRST_NAME": "Firstname-Test",
          "FROM_MIDDLE_NAME": "Middlename-Test",
          "FROM_LAST_NAME": "Lastname-Test",
          "FROM_DOB": "1984-01-01",
          "FROM_FSP_ID": "test-zmw-dfsp",
          "HOME_TRANSACTION_ID": "123ABC",
          "NOTE": "test",
          "P2P_AMOUNT": "10",
          "P2P_CURRENCY": "ZMW",
          "P2P_SOURCE_PARTY_ID_1": "16665551001",
          "P2P_DESTINATION_PARTY_ID_1": "16665551002",
          "FX_SOURCE_PARTY_ID_1": "16665551001",
          "FX_DESTINATION_PARTY_ID_1": "16665551002",
          "FXP1_ID": "testfxp",
          "FX_PAYERDFSP_ID": "test-zmw-dfsp",
          "FX_PAYEEDFSP_ID": "test-mwk-dfsp",
          "FX_SOURCE_CURRENCY": "ZMW",
          "FX_TARGET_CURRENCY": "MWK",
          "FX_SOURCE_AMOUNT": "10"
        }
      }
  ml-testing-toolkit-frontend:
    ingress:
      enabled: false
    nameOverride: ttk-frontend
    fullnameOverride: ttk-frontend
    config:
      API_BASE_URL: https://${ttk_backend_fqdn}

#%{ else}
  enabled: false
#%{ endif}

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
