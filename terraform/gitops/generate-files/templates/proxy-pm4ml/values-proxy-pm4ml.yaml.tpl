
# %{ if length(imagePullSecrets) > 0 }
global:
  imagePullSecrets:
    ${indent(4, imagePullSecrets)}
# %{ endif }

inter-scheme-proxy-adapter:
  image:
    registry: ghcr.io
    repository: infitx-org/inter-scheme-proxy-adapter
  ## Disabling liveness probes temporarily
  readinessProbe: |
    exec:
      command:
      - touch
      - /tmp/healthy
  livenessProbe: |
    exec:
      command:
      - touch
      - /tmp/healthy
  enabled: true
  envFromSecrets:
    OAUTH_CLIENT_SECRET_A:
      secret:
        name: "${pm4ml_external_switch_a_client_secret}"
        key: "${pm4ml_external_switch_client_secret_key}"
    OAUTH_CLIENT_SECRET_B:
      secret:
        name: "${pm4ml_external_switch_b_client_secret}"
        key: "${pm4ml_external_switch_client_secret_key}"

  env:
    LOG_LEVEL: debug
    PROXY_ID: "${proxy_id}"
    INBOUND_LISTEN_PORT_A: 4000
    INBOUND_LISTEN_PORT_B: 4100
    OUTBOUND_MUTUAL_TLS_ENABLED_A: true
    OUTBOUND_MUTUAL_TLS_ENABLED_B: true
    # INCOMING_HEADERS_REMOVAL: 'some-header'
    PEER_ENDPOINT_A: "${scheme_a_config.pm4ml_external_switch_fqdn}"
    PEER_ENDPOINT_B: "${scheme_b_config.pm4ml_external_switch_fqdn}"
    OAUTH_TOKEN_ENDPOINT_A: "${scheme_a_config.pm4ml_external_switch_oidc_url}/${scheme_a_config.pm4ml_external_switch_oidc_token_route}"
    OAUTH_CLIENT_KEY_A: "${proxy_id}-a"
    OAUTH_CLIENT_KEY_B: "${proxy_id}-b"
    OAUTH_REFRESH_SECONDS_A: 3600
    OAUTH_TOKEN_ENDPOINT_B: "${scheme_b_config.pm4ml_external_switch_oidc_url}/${scheme_b_config.pm4ml_external_switch_oidc_token_route}"
    OAUTH_REFRESH_SECONDS_B: 3600
    MGMT_API_WS_URL_A: "${proxy_id}-management-api-a"
    MGMT_API_WS_PORT_A: 4005
    MGMT_API_WS_URL_B: "${proxy_id}-management-api-b"
    MGMT_API_WS_PORT_B: 4005
    PM4ML_ENABLED: true
    CHECK_PEER_JWS_INTERVAL: 1800000

management-api-a:
  enabled: true
  serviceAccountName: ${pm4ml_service_account_name}
  env:
    ENABLE_UI_API_SERVER: false
    DFSP_ID: "${proxy_id}"
    HUB_IAM_PROVIDER_URL: "${scheme_a_config.pm4ml_external_switch_oidc_url}"
    OIDC_TOKEN_ROUTE: "${scheme_a_config.pm4ml_external_switch_oidc_token_route}"
    MCM_SERVER_ENDPOINT: "https://${scheme_a_config.pm4ml_external_mcm_public_fqdn}/pm4mlapi"
    MCM_CLIENT_REFRESH_INTERVAL: 300
    PRIVATE_KEY_LENGTH: 2048
    PRIVATE_KEY_ALGORITHM: rsa
    AUTH_ENABLED: true
    AUTH_CLIENT_ID: ${proxy_id}-a
    CLIENT_SECRET_NAME: ${pm4ml_external_switch_a_client_secret}
    CLIENT_SECRET_KEY: ${pm4ml_external_switch_client_secret_key}
    MCM_CLIENT_SECRETS_LOCATION: /tls
    VAULT_ENDPOINT: ${vault_endpoint}
    VAULT_AUTH_METHOD: K8S
    VAULT_K8S_ROLE: ${pm4ml_vault_k8s_role_name}
    VAULT_K8S_TOKEN_FILE: /var/run/secrets/kubernetes.io/serviceaccount/token
    VAULT_PKI_SERVER_ROLE: ${vault_pki_server_role}
    VAULT_PKI_CLIENT_ROLE: ${vault_pki_client_role}
    VAULT_MOUNT_PKI: ${vault_pki_mount}
    VAULT_MOUNT_KV: ${pm4ml_secret_path}/${proxy_id}/scheme-a
    MOJALOOP_CONNECTOR_FQDN: "${inter_scheme_proxy_adapter_a_fqdn}"
    CALLBACK_URL: "${callback_url_scheme_a}"
    CERT_MANAGER_ENABLED: true
    CERT_MANAGER_SERVER_CERT_SECRET_NAME: ${server_cert_secret_name}
    CERT_MANAGER_SERVER_CERT_SECRET_NAMESPACE: ${server_cert_secret_namespace}
    WHITELIST_IP: "${nat_ip_list}"

management-api-b:
  enabled: true
  serviceAccountName: ${pm4ml_service_account_name}
  env:
    ENABLE_UI_API_SERVER: false
    DFSP_ID: "${proxy_id}"
    HUB_IAM_PROVIDER_URL: "${scheme_b_config.pm4ml_external_switch_oidc_url}"
    OIDC_TOKEN_ROUTE: "${scheme_b_config.pm4ml_external_switch_oidc_token_route}"
    MCM_SERVER_ENDPOINT: "https://${scheme_b_config.pm4ml_external_mcm_public_fqdn}/pm4mlapi"
    MCM_CLIENT_REFRESH_INTERVAL: 300
    PRIVATE_KEY_LENGTH: 2048
    PRIVATE_KEY_ALGORITHM: rsa
    AUTH_ENABLED: true
    AUTH_CLIENT_ID: ${proxy_id}-b
    CLIENT_SECRET_NAME: ${pm4ml_external_switch_b_client_secret}
    CLIENT_SECRET_KEY: ${pm4ml_external_switch_client_secret_key}
    MCM_CLIENT_SECRETS_LOCATION: /tls
    VAULT_ENDPOINT: ${vault_endpoint}
    VAULT_AUTH_METHOD: K8S
    VAULT_K8S_ROLE: ${pm4ml_vault_k8s_role_name}
    VAULT_K8S_TOKEN_FILE: /var/run/secrets/kubernetes.io/serviceaccount/token
    VAULT_PKI_SERVER_ROLE: ${vault_pki_server_role}
    VAULT_PKI_CLIENT_ROLE: ${vault_pki_client_role}
    VAULT_MOUNT_PKI: ${vault_pki_mount}
    VAULT_MOUNT_KV: ${pm4ml_secret_path}/${proxy_id}/scheme-b
    MOJALOOP_CONNECTOR_FQDN: "${inter_scheme_proxy_adapter_b_fqdn}"
    CALLBACK_URL: "${callback_url_scheme_b}"
    CERT_MANAGER_ENABLED: true
    CERT_MANAGER_SERVER_CERT_SECRET_NAME: ${server_cert_secret_name}
    CERT_MANAGER_SERVER_CERT_SECRET_NAMESPACE: ${server_cert_secret_namespace}
    WHITELIST_IP: "${nat_ip_list}"


ttk:
# %{ if ttk_enabled }
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
        "CALLBACK_ENDPOINT": "http://${proxy_id}-inter-scheme-proxy-adapter:4000",
        "SEND_CALLBACK_ENABLE": true,
        "DEFAULT_ENVIRONMENT_FILE_NAME": "pm4ml-default-environment.json",
        "DEFAULT_REQUEST_TIMEOUT": 15000,
        "FSPID": "${proxy_id}"
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

# %{ else }
  enabled: false
# %{ endif }

