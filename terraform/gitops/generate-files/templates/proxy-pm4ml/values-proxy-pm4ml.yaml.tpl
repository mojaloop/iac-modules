

# this should be set to the FSPID assigned by the mojaloop hub to this DFSP
dfspId: &dfspId "${dfsp_id}"

PROXY_ID: &proxyId "proxy1"

inter-scheme-proxy-adapter:
  enabled: true
  envFromSecrets:
    OAUTH_CLIENT_KEY_A:
      secret:
        name: "${pm4ml_external_switch_client_secret}"
        key: "${pm4ml_external_switch_client_id}"
    OAUTH_CLIENT_SECRET_A:
      secret:
        name: "${pm4ml_external_switch_client_secret}"
        key: "${pm4ml_external_switch_client_secret_key}"
    OAUTH_CLIENT_KEY_B:
      secret:
        name: "${pm4ml_external_switch_client_secret}"
        key: "${pm4ml_external_switch_client_id}"
    OAUTH_CLIENT_SECRET_B:
      secret:
        name: "${pm4ml_external_switch_client_secret}"
        key: "${pm4ml_external_switch_client_secret_key}"

  env:
    LOG_LEVEL: info
    PROXY_ID: *proxyId
    INBOUND_LISTEN_PORT_A: 4000
    INBOUND_LISTEN_PORT_B: 4100
    OUTBOUND_MUTUAL_TLS_ENABLED_A: true
    OUTBOUND_MUTUAL_TLS_ENABLED_B: true
    PEER_ENDPOINT_A: "${pm4ml_external_switch_fqdn}"
    PEER_ENDPOINT_B: "${pm4ml_external_switch_fqdn}"
    OAUTH_TOKEN_ENDPOINT_A: "${pm4ml_external_switch_oidc_url}/${pm4ml_external_switch_oidc_token_route}"
    OAUTH_REFRESH_SECONDS_A: 3600
    OAUTH_TOKEN_ENDPOINT_B: "${pm4ml_external_switch_oidc_url}/${pm4ml_external_switch_oidc_token_route}"
    OAUTH_REFRESH_SECONDS_B: 3600
    MGMT_API_WS_URL_A: "${pm4ml_release_name}-management-api"
    MGMT_API_WS_PORT_A: 4005
    MGMT_API_WS_URL_B: "${pm4ml_release_name}-management-api"
    MGMT_API_WS_PORT_B: 4005
    PM4ML_ENABLED: true

management-api-service-a: 
  enabled: true
  image:
    tag: 5.0.0-snapshot.2
  serviceAccountName: ${pm4ml_service_account_name}
  env:
    CACHE_URL: redis://${redis_host}:${redis_port}
    DFSP_ID: *proxyId
    HUB_IAM_PROVIDER_URL: "${pm4ml_external_switch_oidc_url}"
    OIDC_TOKEN_ROUTE: "${pm4ml_external_switch_oidc_token_route}"
    MCM_SERVER_ENDPOINT: "${mcm_host_url}/pm4mlapi"
    MCM_CLIENT_REFRESH_INTERVAL: 300
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

management-api-service-b:
  enabled: true
  image:
    tag: 5.0.0-snapshot.2
  serviceAccountName: ${pm4ml_service_account_name}
  env:
    CACHE_URL: redis://${redis_host}:${redis_port}
    DFSP_ID: *proxyId
    HUB_IAM_PROVIDER_URL: "${pm4ml_external_switch_oidc_url}"
    OIDC_TOKEN_ROUTE: "${pm4ml_external_switch_oidc_token_route}"
    MCM_SERVER_ENDPOINT: "${mcm_host_url}/pm4mlapi"
    MCM_CLIENT_REFRESH_INTERVAL: 300
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


ttk:
%{ if ttk_enabled ~}
  enabled: true
  ml-testing-toolkit-backend:
    image:
      repository: mojaloop/ml-testing-toolkit
      tag: v17.2.0
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
        "DEFAULT_REQUEST_TIMEOUT": 15000,
        "FSPID": *proxyId
      }

  ml-testing-toolkit-frontend:
    image:
      repository: mojaloop/ml-testing-toolkit-ui
      tag: v15.5.0-snapshot.1
    ingress:
      enabled: false
    nameOverride: ttk-frontend
    fullnameOverride: ttk-frontend
    config:
      API_BASE_URL: https://${ttk_backend_fqdn}

%{ else ~}
  enabled: false
%{ endif ~}

