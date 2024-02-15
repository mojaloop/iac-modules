global:
  adminApiSvc:
    host: ${central_admin_host}
    port: 80
  settlementSvc:
    host: ${central_settlements_host}
    port: 80
  keto:
    readURL: ${keto_read_url}
    writeURL: ${keto_write_url}
  reportingDB:
    host: ${reporting_db_host}
    port: ${reporting_db_port}
    user: ${reporting_db_user}
    database: ${reporting_db_database}
    secret:
      name: ${reporting_db_secret_name}
      key: ${reporting_db_secret_key}
  reportingEventsDB:
    host: ${reporting_events_mongodb_host}
    port: ${reporting_events_mongodb_port}
    user: ${reporting_events_mongodb_user}
    database: ${reporting_events_mongodb_database}
    secret:
      name: ${reporting_events_mongodb_existing_secret}
      key: mongodb-passwords
  kafka:
    host: ${kafka_host}
    port: ${kafka_port}
  rolePermOperator:
    apiSvc:
      host: ${bof_role_perm_operator_host}
      port: 80
  keycloak:
    url: 'https://${keycloak_fqdn}'
    user: '${role_assign_service_user}'
    secret:
      name: '${role_assign_service_secret}'
      key: '${role_assign_service_secret_key}'
    realm: '${keycloak_realm_name}'

## TODO: Disabling the tests by default for now. Need to figure out how to configure the tests.
## RBAC Tests
rbacTests:
  enabled: false

## Report Tests
reportTests:
  enabled: false

## Backend API services

role-assignment-service:
  enabled: true
  ingress:
    enabled: false
  configFiles:
    default.json: {
        "ROLES_LIST": [
          "manager",
          "operator",
          "clerk",
          "financeManager",
          "dfspReconciliationReports",
          "audit",
          "mcmadmin"
        ],
        "AUTO_GRANT_PORTAL_ADMIN_ROLES": [
          "manager"
        ]
      }

reporting-hub-bop-api-svc:
  containerSecurityContext:
    enabled: false
  enabled: true
  ingress:
    enabled: false
    

reporting-legacy-api:
  containerSecurityContext:
    enabled: false
  enabled: true
  ingress:
    enabled: false
  install-templates: false
  auth: true
  config:
    env:
      VALIDATION_RETRY_COUNT: "10"
      VALIDATION_RETRY_INTERVAL_MS: "5000"
  reporting-k8s-templates:
    templates:
      settlement: true
      dfspSettlement: true
      dfspSettlementDetail: true
      reconciliationAmount: true
      settlementWindow: true
      settlementInitiation: true
      transactionReconciliation: true
      dfspSettlementStatement: true
      settlementAudit: true

reporting-events-processor-svc:
  enabled: true
  kafka:
    host: ${kafka_host}
    port: ${kafka_port}
    topicEvent: topic-event
    consumerGroup: reporting_events_processor_consumer_group
    clientId: reporting_events_processor_consumer

reporting-hub-bop-experience-api-svc:
  enabled: true

## Front-end UI services
reporting-hub-bop-shell:
  enabled: true
  ingress:
    enabled: false
    
  config:
    env:
      AUTH_MOCK_API: false
      REMOTE_API_BASE_URL: ''
      REMOTE_MOCK_API: false
      LOGIN_URL: https://${auth_fqdn}/kratos/self-service/login/browser?return_to=https://${portal_fqdn}
      LOGOUT_URL: https://${auth_fqdn}/kratos/self-service/logout/browser
      AUTH_TOKEN_URL: /kratos/sessions/whoami
      AUTH_ENABLED: true
      REMOTE_1_URL: https://${portal_fqdn}/uis/iam
      REMOTE_2_URL: https://${portal_fqdn}/uis/transfers
      REMOTE_3_URL: https://${portal_fqdn}/uis/settlements
      REMOTE_4_URL: https://${portal_fqdn}/uis/positions

### Micro-frontends
reporting-hub-bop-role-ui:
  enabled: true
  ingress:
    enabled: false
  config:
    env:
      REACT_APP_API_BASE_URL: https://${portal_fqdn}/api/iam
      REACT_APP_MOCK_API: false

reporting-hub-bop-trx-ui:
  enabled: true
  ingress:
    enabled: false
  config:
    env:
      REACT_APP_API_BASE_URL: https://${portal_fqdn}/api/transfers
      REACT_APP_MOCK_API: false

reporting-hub-bop-settlements-ui:
  ## Overriding the image version for bugfix related to https://modusbox.atlassian.net/browse/MBP-639
  image:
    registry: docker.io
    repository: mojaloop/reporting-hub-bop-settlements-ui
    tag: v0.0.17
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/api/central-admin
      CENTRAL_SETTLEMENTS_ENDPOINT: https://${portal_fqdn}/api/central-settlements
      REPORTING_API_ENDPOINT: https://${portal_fqdn}/api/transfers
  ingress:
    enabled: false
    

reporting-hub-bop-positions-ui:
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/api/central-admin
  ingress:
    enabled: false
