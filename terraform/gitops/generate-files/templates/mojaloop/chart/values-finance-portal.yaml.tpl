global:
  adminApiSvc:
    host: ${central_admin_host} #TODO
    port: 80
  settlementSvc:
    host: ${central_settlements_host} #TODO
    port: 80
  keto:
    readURL: "http://keto-read.${ory_namespace}:80"
  reportingDB:
    host: ${central_ledger_db_host}
    port: ${central_ledger_db_port}
    user: ${central_ledger_db_user}
    database: ${central_ledger_db_database}
    secret:
      name: ${central_ledger_db_existing_secret}
      key: mysql-password
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

finance-portal:
  ## TODO: Disabling the tests by default for now. Need to figure out how to configure the tests.
  ## RBAC Tests
  rbacTests:
    enabled: false

  ## Report Tests
  reportTests:
    enabled: false

  ## Backend API services
  reporting-hub-bop-api-svc:
    enabled: true
    ingress:
      enabled: false
      hostname: ${api_fqdn}
      path: /transfers(/|$)(.*)
      annotations:
        kubernetes.io/ingress.class: nginx
        nginx.ingress.kubernetes.io/rewrite-target: /$2

  reporting-legacy-api:
    enabled: true
    ingress:
      enabled: false
      hostname: ${api_fqdn}
      path: /reports(/|$)(.*)
      annotations:
        kubernetes.io/ingress.class: nginx
        nginx.ingress.kubernetes.io/rewrite-target: /$2
    install-templates: true
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
      hostname: ${portal_fqdn}
      annotations:
        kubernetes.io/ingress.class: nginx
        #cert-manager.io/cluster-issuer: letsencrypt
      tls: true
      selfSigned: true
      tlsSetSecretManual: true
      tlsManualSecretName: ""
    config:
      env:
        AUTH_MOCK_API: false
        REMOTE_API_BASE_URL: /
        REMOTE_MOCK_API: false
        LOGIN_URL: /kratos/self-service/registration/browser
        LOGOUT_URL: /kratos/self-service/browser/flows/logout
        AUTH_TOKEN_URL: /kratos/sessions/whoami
        AUTH_ENABLED: true
        REMOTE_1_URL: https://${iamui_fqdn}
        REMOTE_2_URL: https://${transfersui_fqdn}
        REMOTE_3_URL: https://${settlementsui_fqdn}
        REMOTE_4_URL: https://${positionsui_fqdn}

  ### Micro-frontends
  reporting-hub-bop-role-ui:
    enabled: true
    ingress:
      enabled: false
      pathType: ImplementationSpecific
      hostname: ${iamui_fqdn}
      path: /
      annotations:
        kubernetes.io/ingress.class: nginx
        #cert-manager.io/cluster-issuer: letsencrypt
      tls: true
      selfSigned: true
      tlsSetSecretManual: true
      tlsManualSecretName: ""
    config:
      env:
        REACT_APP_API_BASE_URL: https://${portal_fqdn}/proxy/iam
        REACT_APP_MOCK_API: false

  reporting-hub-bop-trx-ui:
    enabled: true
    ingress:
      enabled: false
      pathType: ImplementationSpecific
      hostname: ${transfersui_fqdn}
      annotations:
        kubernetes.io/ingress.class: nginx
        #cert-manager.io/cluster-issuer: letsencrypt
      tls: true
      selfSigned: true
      tlsSetSecretManual: true
      tlsManualSecretName: ""
    config:
      env:
        REACT_APP_API_BASE_URL: https://${portal_fqdn}/proxy/transfers
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
        CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/proxy/central-admin
        CENTRAL_SETTLEMENTS_ENDPOINT: https://${portal_fqdn}/proxy/central-settlements
        REPORTING_API_ENDPOINT: https://${portal_fqdn}/proxy/transfers
    ingress:
      enabled: false
      pathType: ImplementationSpecific
      hostname: ${settlementsui_fqdn}
      annotations:
        kubernetes.io/ingress.class: nginx
        #cert-manager.io/cluster-issuer: letsencrypt
      tls: true
      selfSigned: true
      tlsSetSecretManual: true
      tlsManualSecretName: ""

  reporting-hub-bop-positions-ui:
    enabled: true
    config:
      env:
        CENTRAL_LEDGER_ENDPOINT: https://${portal_fqdn}/proxy/central-admin
    ingress:
      enabled: false
      pathType: ImplementationSpecific
      hostname: ${positionsui_fqdn}
      annotations:
        kubernetes.io/ingress.class: nginx
        #cert-manager.io/cluster-issuer: letsencrypt
      tls: true
      selfSigned: true
      tlsSetSecretManual: true
      tlsManualSecretName: ""

