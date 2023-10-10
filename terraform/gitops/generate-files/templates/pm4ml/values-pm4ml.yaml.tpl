mojaloop-payment-manager:  
  ingress:
    enabled: false

  experienceApiClientSecret: &experienceApiClientSecret "38f84299-d9b4-4d4e-a195-c1996d028406"

  frontendRootUrl: &frontendRootUrl "https://portal.${public_subdomain}/"
  frontendBaseUrl: &frontendBaseUrl "https://experience-api.${public_subdomain}/"

  # this needs to have external URLs of both the UI and experience API
  frontendRedirectUris: &frontendRedirectUris
    - "https://portal.${public_subdomain}/*"
    - "https://experience-api.${public_subdomain}/*"

  # this _should_ be set to only allow requests from known origins
  frontendWebOrigins: &frontendWebOrigins
    - "*"

  # this should be set to the FSPID assigned by the mojaloop hub to this DFSP
  dfspId: &dfspId "${dfsp_id}"

  frontend:
    env:
      API_BASE_URL: "https://experience-api.${public_subdomain}"

  experience-api:
    env:
      enableMockData: false
      managementEndPoint: "${pm4ml_release_name}-management-api"
      dfspId: *dfspId
      appKeys: ootu1yoo5geeS7izai4ox1Yae1Eey6ai
      authClientSecret: *experienceApiClientSecret
      metricsEndPoint: "${pm4ml_release_name}-prometheus-server"
      authDiscoveryEndpoint: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/.well-known/openid-configuration"
      # this should be set to the external URL of the auth endpoint on the experience API
      authRedirectUri: "https://experience-api.${public_subdomain}/auth"
      # this should be set to the external URL of the UI
      authLoggedInLandingUrl: "https://portal.${public_subdomain}/"
      authSessionSecure: false

  management-api:
    serviceAccountName: {{ item.key }}-vault-pm4ml-auth
    env:
      CACHE_URL: ${redis_host}:${redis_port}
      DFSP_ID: *dfspId
      MCM_SERVER_ENDPOINT: "${mcm_host_url}/api"
      MCM_CLIENT_REFRESH_INTERVAL: 60
      PRIVATE_KEY_LENGTH: 2048
      PRIVATE_KEY_ALGORITHM: rsa
      AUTH_ENABLED: ${mcm_auth_enabled}
      AUTH_USER: ${mcm_auth_user}
      AUTH_PASS: ${mcm_auth_pass}
      MCM_CLIENT_SECRETS_LOCATION: /tls
      VAULT_ENDPOINT: ${vault_endpoint}
      VAULT_AUTH_METHOD: K8S
      VAULT_K8S_ROLE: vault-pm4ml-auth
      VAULT_K8S_TOKEN_FILE: /var/run/secrets/kubernetes.io/serviceaccount/token
      VAULT_PKI_SERVER_ROLE: ${public_subdomain}
      VAULT_PKI_CLIENT_ROLE: ${public_subdomain}
      VAULT_MOUNT_PKI: pki-${public_subdomain}-${dfsp_id}
      VAULT_MOUNT_KV: secrets/pm4ml/${dfsp_id}
      MOJALOOP_CONNECTOR_FQDN: "connector.${public_subdomain}"
      CALLBACK_URL: "connector.${public_subdomain}:9443"
      CERT_MANAGER_ENABLED: true
      CERT_MANAGER_SERVER_CERT_SECRET_NAME: ${server_cert_secret_name}
      CERT_MANAGER_SERVER_CERT_SECRET_NAMESPACE: ${server_cert_secret_namespace}
      WHITELIST_IP: ${nat_ip_list}
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
      {% if enable_sdk_bulk_transaction_support == "yes" %}
      kafka: &kafkaConfig
        host: ${kafka_host}
        port: ${kafka_port}
      {% endif %}
      redis: &redisConfig
        host: ${redis_host}
        port: ${redis_port}
      config:
        simName: *dfspId
        {% if enable_sdk_bulk_transaction_support == "yes" %}
        bulkTransactionSupportEnabled: true
        {% else %}
        bulkTransactionSupportEnabled: false
        {% endif %}
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
        PEER_ENDPOINT: "${mojaloop_switch_fqdn}/fsp/1.0"
        ALS_ENDPOINT: "${mojaloop_switch_fqdn}/fsp/1.0"
        OUTBOUND_MUTUAL_TLS_ENABLED: true
        INBOUND_MUTUAL_TLS_ENABLED: false
        OAUTH_TOKEN_ENDPOINT: "${token_endpoint}"
        OAUTH_CLIENT_KEY: "{{ item.value.extgw_client_key }}"
        OAUTH_CLIENT_SECRET: "{{ item.value.extgw_client_secret }}"
        {% if item.value.use_ttk_as_backend_simulator == "yes" %}
        BACKEND_ENDPOINT: "${pm4ml_release_name}-ttk-backend:4040"
        {% else %}
        BACKEND_ENDPOINT: "${pm4ml_release_name}-mojaloop-core-connector:3003"
        {% endif %}
        MGMT_API_WS_URL: "${pm4ml_release_name}-management-api"
        {% if item.value.enable_sdk_bulk_transaction_support == "yes" %}
        ENABLE_BACKEND_EVENT_HANDLER: true
        ENABLE_FSPIOP_EVENT_HANDLER: true
        REQUEST_PROCESSING_TIMEOUT_SECONDS: 30
        {% endif %}

    {% if enable_sdk_bulk_transaction_support == "yes" %}
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
    {% endif %}

  redis:
    replica:
      replicaCount: {{ redis_replica_count }}
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
      storageClass: ${storage_class}

  ttk:
    {% if ttk_enabled == "yes" %}
    enabled: true
    ml-testing-toolkit-backend:
      nameOverride: ttk-backend
      fullnameOverride: ttk-backend
      config:
        user_config.json: {
          "VERSION": 1,
          "CALLBACK_ENDPOINT": "http://${pm4ml_release_name}-sdk-scheme-adapter-api-svc:4001",
          "SEND_CALLBACK_ENABLE": true,
          "DEFAULT_ENVIRONMENT_FILE_NAME": "pm4ml-default-environment.json",
          "FSPID": *dfspId
        }

    ml-testing-toolkit-frontend:
      nameOverride: ttk-frontend
      fullnameOverride: ttk-frontend
    {% else %}
    enabled: false
    {% endif %}


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
