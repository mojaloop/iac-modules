# Default values for kratos.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
# -- Number of replicas in deployment
replicaCount: 1


imagePullSecrets: []
nameOverride: ""
fullnameOverride: "kratos"

deployment:
  extraEnv:
    - name: SELFSERVICE_METHODS_OIDC_CONFIG_PROVIDERS
      valueFrom:
        secretKeyRef:
          name: kratos-oidc-providers
          key: value

## -- Secret management
secret:
  # -- switch to false to prevent creating the secret
  enabled: false
  # -- Provide custom name of existing secret, or custom name of secret to be created
  nameOverride: "${kratos_dsn_secretname}"
  
## -- Application specific config
kratos:
  development: false
  # -- Enable the initialization job. Required to work with a DB
  automigration:
    enabled: true
    type: initContainer

  # -- You can add multiple identity schemas here
  identity:
    default_schema_id: default
    schemas:
      - id: default
        url: file:///etc/config/kratos/identity.schema.json

  config:
    # dsn: memory
    #bogus entry here, required?
    courier:
      smtp:
        connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true
    serve:
      public:
        base_url: https://${auth_fqdn}/kratos/
        port: 4433
        cors:
          enabled: true
      admin:
        port: 4434

    selfservice:
      default_browser_return_url: https://${auth_fqdn}/
      whitelisted_return_urls:
        - https://${auth_fqdn}/

      methods:
        oidc:
          enabled: true
            
      flows:
        error:
          ui_url: https://${auth_fqdn}/selfui/error

        settings:
          ui_url: https://${auth_fqdn}/selfui/settings
          privileged_session_max_age: 15m

        recovery:
          enabled: true
          ui_url: https://${auth_fqdn}/selfui/recovery

        verification:
          enabled: true
          ui_url: https://${auth_fqdn}/selfui/verify
          after:
            default_browser_return_url: https://${auth_fqdn}/selfui/

        login:
          ui_url: https://${auth_fqdn}/selfui/auth/login
          lifespan: 10m

        logout:
          after:
            default_browser_return_url: ${keycloak_fqdn}/oidc/logout

        registration:
          lifespan: 10m
          ui_url: https://${auth_fqdn}/selfui/auth/
          after:
            oidc:
              hooks:
                - hook: session
    log:
      level: debug
      format: text
      leak_sensitive_values: true

    secrets:
      cookie:
        - PLEASE-CHANGE-ME-I-AM-VERY-INSECURE
      cipher:
        - 32-LONG-SECRET-NOT-SECURE-AT-ALL

    ciphers:
      algorithm: xchacha20-poly1305

    hashers:
      algorithm: bcrypt
      bcrypt:
        cost: 8



## -- Parameters for the Prometheus ServiceMonitor objects.
# Reference: https://docs.openshift.com/container-platform/4.6/rest_api/monitoring_apis/servicemonitor-monitoring-coreos-com-v1.html
serviceMonitor:
  # -- switch to true to enable creating the ServiceMonitor
  enabled: true
  # -- HTTP scheme to use for scraping.
  scheme: http
  # -- Interval at which metrics should be scraped
  scrapeInterval: 60s
  # -- Timeout after which the scrape is ended
  scrapeTimeout: 30s
  # -- Provide additional labels to the ServiceMonitor ressource metadata
  labels: {}
  # -- TLS configuration to use when scraping the endpoint
  tlsConfig: {}