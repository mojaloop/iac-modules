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
  nameOverride: kratos-secret
#turning off email services
courier:
  enabled: false
## -- Application specific config
kratos:
  development: false
  # -- Enable the initialization job. Required to work with a DB
  automigration:
    enabled: true
    type: initContainer

  # -- You can add multiple identity schemas here
  identitySchemas:
    "identity.default.schema.json": |
      {
        "$id": "https://mojaloop.io/kratos-schema/identity.schema.json",
        "$schema": "http://json-schema.org/draft-07/schema#",
        "title": "Person",
        "type": "object",
        "properties": {
          "traits": {
            "type": "object",
            "properties": {
              "email": {
                "title": "E-Mail",
                "type": "string",
                "format": "email"
              },
              "subject": {
                "title": "Subject",
                "type": "string"
              },
              "name": {
                "title": "Name",
                "type": "string"
              }
            }
          }
        }
      }

  config:
    #bogus entry here, required?
    courier:
      smtp:
        connection_uri: smtps://test:test@mailslurper:1025/?skip_ssl_verify=true
    identity:
      default_schema_id: default
      schemas:
        - id: default
          url: file:///etc/config/identity.default.schema.json
    serve:
      public:
        base_url: https://${auth_fqdn}/kratos/
        port: 4433
        cors:
          enabled: true
      admin:
        port: 4434

    selfservice:
      default_browser_return_url: https://${auth_fqdn}/ui/welcome
      allowed_return_urls:
        - https://${auth_fqdn}/ui
# %{ for fqdnItem in bof_managed_portal_fqdns ~}
        - https://${fqdnItem}
# %{ endfor ~}

      methods:
        password:
          enabled: false
        oidc:
          enabled: true

      flows:

        login:
          ui_url: https://${auth_fqdn}/ui/login
          lifespan: 10m
          after:
            oidc:
              default_browser_return_url: https://${auth_fqdn}/ui/welcome

        logout:
          after:
            default_browser_return_url: ${keycloak_fqdn}/oidc/logout

        error:
          ui_url: https://${auth_fqdn}/ui/error
        # registration:
        #   lifespan: 10m
        #   ui_url: https://${auth_fqdn}/ui/login/
        #   after:
        #     oidc:
        #       hooks:
        #         - hook: session

    log:
      level: debug
      format: text
      leak_sensitive_values: true

    ciphers:
      algorithm: xchacha20-poly1305

    hashers:
      algorithm: bcrypt
      bcrypt:
        cost: 8
    session:
      cookie:
        domain: ${public_subdomain}



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
