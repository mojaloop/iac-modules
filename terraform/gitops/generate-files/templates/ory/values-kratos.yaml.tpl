# Default values for kratos.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.
# -- Number of replicas in deployment
replicaCount: 1


imagePullSecrets: []
nameOverride: ""
fullnameOverride: "kratos"



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
    # dsn: memory
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
          config:
            providers:
            - id: idp
              provider: generic
              # TODO both the client_id and client_secret need to be set appropriately to the client supporting authorization code grants with openid
              # TODO these can alternatively be set via environment variable from a k8s secret
              client_id: ${keycloak_client_id}
              client_secret: ${keycloak_client_secret}
              # mapper_url: file:///etc/config2/oidc.jsonnet
              mapper_url: base64://bG9jYWwgY2xhaW1zID0gc3RkLmV4dFZhcignY2xhaW1zJyk7Cgp7CiAgaWRlbnRpdHk6IHsKICAgIHRyYWl0czogewogICAgICBlbWFpbDogY2xhaW1zLmVtYWlsLAogICAgICBuYW1lOiBjbGFpbXMuZW1haWwsCiAgICAgIHN1YmplY3Q6IGNsYWltcy5zdWIKICAgIH0sCiAgfSwKfQ==
              # issuer_url is the OpenID Connect Server URL. You can leave this empty if `provider` is not set to `generic`.
              # If set, neither `auth_url` nor `token_url` are required.
              issuer_url: ${keycloak_host}/oauth2/token

              # auth_url is the authorize url, typically something like: https://example.org/oauth2/auth
              # Should only be used when the OAuth2 / OpenID Connect server is not supporting OpenID Connect Discovery and when
              # `provider` is set to `generic`.
              # auth_url: http://openid-connect-provider/oauth2/auth

              # token_url is the token url, typically something like: https://example.org/oauth2/token
              # Should only be used when the OAuth2 / OpenID Connect server is not supporting OpenID Connect Discovery and when
              # `provider` is set to `generic`.
              # token_url: http://openid-connect-provider/oauth2/token
              scope:
              # # TODO adjust requested scope based on IdP (WSO2) documentation
              - openid
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
            default_browser_return_url: ${keycloak_host}/oidc/logout

        registration:
          lifespan: 10m
          ui_url: https://${auth_fqdn}/selfui/auth/
          after:
            oidc:
              hooks:
                - hook: session
    secrets:
      cookie:
        - PLEASE-CHANGE-ME-I-AM-VERY-INSECURE
    hashers:
      argon2:
        parallelism: 1
        ## This one is changed in the new kratos version
        ## This change is because the kratos docker image version is overridden to older version. See the comments at image parameter above.
        # memory: "128MB"
        memory: 120000
        iterations: 3
        salt_length: 16
        key_length: 32
    identity:
      default_schema_url: file:///etc/config/identity.default.schema.json



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