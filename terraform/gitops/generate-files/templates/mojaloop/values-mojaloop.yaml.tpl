# Custom YAML TEMPLATE Anchors
CONFIG:
  ## ACCOUNT-LOOKUP BACKEND
  als_db_database: &ALS_DB_DATABASE "${account_lookup_db_database}"
  als_db_password: &ALS_DB_PASSWORD ""
  als_db_secret: &ALS_DB_SECRET
    name: &ALS_DB_SECRET_NAME "${account_lookup_db_existing_secret}"
    key: &ALS_DB_SECRET_KEY mysql-password
  als_db_host: &ALS_DB_HOST "${account_lookup_db_host}"
  als_db_port: &ALS_DB_PORT ${account_lookup_db_port}
  als_db_user: &ALS_DB_USER "${account_lookup_db_user}"

  ## CENTRAL-LEDGER BACKEND
  cl_db_database: &CL_DB_DATABASE "${central_ledger_db_database}"
  cl_db_password: &CL_DB_PASSWORD ""
  cl_db_secret: &CL_DB_SECRET
    name: &CL_DB_SECRET_NAME "${central_ledger_db_existing_secret}"
    key: &CL_DB_SECRET_KEY mysql-password
  cl_db_host: &CL_DB_HOST "${central_ledger_db_host}"
  cl_db_port: &CL_DB_PORT ${central_ledger_db_port}
  cl_db_user: &CL_DB_USER "${central_ledger_db_user}"

  ## KAFKA BACKEND
  kafka_host: &KAFKA_HOST "${kafka_host}"
  kafka_port: &KAFKA_PORT ${kafka_port}

  ## BULK OBJECT STORE BACKEND
  obj_mongo_host: &OBJSTORE_MONGO_HOST "${cl_mongodb_host}"
  obj_mongo_port: &OBJSTORE_MONGO_PORT ${cl_mongodb_port}
  obj_mongo_user: &OBJSTORE_MONGO_USER "${cl_mongodb_user}"
  obj_mongo_password: &OBJSTORE_MONGO_PASSWORD ""
  obj_mongo_secret: &OBJSTORE_MONGO_SECRET
    name: &OBJSTORE_MONGO_SECRET_NAME "${cl_mongodb_existing_secret}"
    key: &OBJSTORE_MONGO_SECRET_KEY mongodb-passwords
  obj_mongo_database: &OBJSTORE_MONGO_DATABASE "${cl_mongodb_database}"

  ## MOJALOOP-TTK-SIMULATORS BACKEND
  moja_ttk_sim_kafka_host: &MOJA_TTK_SIM_KAFKA_HOST "${kafka_host}"
  moja_ttk_sim_kafka_port: &MOJA_TTK_SIM_KAFKA_PORT ${kafka_port}
  moja_ttk_sim_redis_host: &MOJA_TTK_SIM_REDIS_HOST "${ttksims_redis_host}"
  moja_ttk_sim_redis_port: &MOJA_TTK_SIM_REDIS_PORT ${ttksims_redis_port}

  ## THIRDPARTY AUTH-SVC BACKEND
  tp_auth_svc_db_database: &TP_AUTH_SVC_DB_DATABASE "${third_party_auth_db_database}"
  tp_auth_svc_db_password: &TP_AUTH_SVC_DB_PASSWORD ""
  tp_auth_svc_db_secret: &TP_AUTH_SVC_DB_SECRET
    name: &TP_AUTH_SVC_DB_SECRET_NAME "${third_party_auth_db_existing_secret}"
    key: &TP_AUTH_SVC_DB_SECRET_KEY mysql-password
  tp_auth_svc_db_host: &TP_AUTH_SVC_DB_HOST "${third_party_auth_db_host}"
  tp_auth_svc_db_port: &TP_AUTH_SVC_DB_PORT ${third_party_auth_db_port}
  tp_auth_svc_db_user: &TP_AUTH_SVC_DB_USER "${third_party_auth_db_user}"
  tp_auth_svc_redis_host: &TP_AUTH_SVC_REDIS_HOST "${third_party_auth_redis_host}"
  tp_auth_svc_redis_port: &TP_AUTH_SVC_REDIS_PORT ${third_party_auth_redis_port}

  ## THIRDPARTY ALS_CONSENT-SVC BACKEND
  tp_als_consent_svc_db_database: &TP_ALS_CONSENT_SVC_DB_DATABASE "${third_party_consent_db_database}"
  tp_als_consent_svc_db_password: &TP_ALS_CONSENT_SVC_DB_PASSWORD ""
  tp_als_consent_svc_db_secret: &TP_ALS_CONSENT_SVC_DB_SECRET
    name: &TP_ALS_CONSENT_SVC_DB_SECRET_NAME "${third_party_consent_db_existing_secret}"
    key: &TP_ALS_CONSENT_SVC_DB_SECRET_KEY mysql-password
  tp_als_consent_svc_db_host: &TP_ALS_CONSENT_SVC_DB_HOST "${third_party_consent_db_host}"
  tp_als_consent_svc_db_port: &TP_ALS_CONSENT_SVC_DB_PORT ${third_party_consent_db_port}
  tp_als_consent_svc_db_user: &TP_ALS_CONSENT_SVC_DB_USER "${third_party_consent_db_user}"

  ## CENTRAL-SETTLEMENT BACKEND
  cs_db_host: &CS_DB_HOST "${central_settlement_db_host}"
  cs_db_password: &CS_DB_PASSWORD ""
  cs_db_secret: &CS_DB_SECRET
    name: &CS_DB_SECRET_NAME "${central_settlement_db_existing_secret}"
    key: &CS_DB_SECRET_KEY mysql-password
  cs_db_user: &CS_DB_USER "${central_settlement_db_user}"
  cs_db_port: &CS_DB_PORT ${central_settlement_db_port}
  cs_db_database: &CS_DB_DATABASE "${central_settlement_db_database}"

  ## QUOTING BACKEND
  quoting_db_host: &QUOTING_DB_HOST "${quoting_db_host}"
  quoting_db_password: &QUOTING_DB_PASSWORD ""
  quoting_db_secret: &QUOTING_DB_SECRET
    name: &QUOTING_DB_SECRET_NAME "${quoting_db_existing_secret}"
    key: &QUOTING_DB_SECRET_KEY mysql-password
  quoting_db_user: &QUOTING_DB_USER "${quoting_db_user}"
  quoting_db_port: &QUOTING_DB_PORT ${quoting_db_port}
  quoting_db_database: &QUOTING_DB_DATABASE "${quoting_db_database}"

  ## TTK MONGODB BACKEND
  ttk_mongo_host: &TTK_MONGO_HOST "${ttk_mongodb_host}"
  ttk_mongo_port: &TTK_MONGO_PORT "${ttk_mongodb_port}"
  ttk_mongo_user: &TTK_MONGO_USER "${ttk_mongodb_user}"
  ttk_mongo_password: &TTK_MONGO_PASSWORD ""
  ttk_mongo_secret: &TTK_MONGO_SECRET
    name: &TTK_MONGO_SECRET_NAME "${ttk_mongodb_existing_secret}"
    key: &TTK_MONGO_SECRET_KEY mongodb-passwords
  ttk_mongo_database: &TTK_MONGO_DATABASE "${ttk_mongodb_database}"

  ## BATCH_PROCESSING: To enable batch processing set following to true
  batch_processing_enabled: &CL_BATCH_PROCESSING_ENABLED ${central_ledger_handler_transfer_position_batch_processing_enabled}

  ## CENTRAL-LEDGER CACHE
  cl_cache_enabled: &CL_CACHE_ENABLED ${central_ledger_cache_enabled}
  cl_cache_expires_in_ms: &CL_CACHE_EXPIRES_IN_MS ${central_ledger_cache_expires_in_ms}

  ## MONITORING
  ml_api_adapter_monitoring_prefix : &ML_API_ADAPTER_MONITORING_PREFIX "${ml_api_adapter_monitoring_prefix}"
  quoting_monitoring_prefix: &QUOTING_MONITORING_PREFIX "${quoting_service_monitoring_prefix}"
  cl_monitoring_prefix: &CL_MONITORING_PREFIX "${central_ledger_monitoring_prefix}"
  als_monitoring_prefix: &ALS_MONITORING_PREFIX "${account_lookup_service_monitoring_prefix}"

  ingress_class: &INGRESS_CLASS "${ingress_class_name}"

  ## Endpiont Security
  endpointSecurity: &ENDPOINT_SECURITY
    jwsSigningKeySecret: &JWS_SIGNING_KEY_SECRET
      name: ${jws_key_secret}
      key: ${jws_key_secret_private_key_key}
%{ if mojaloop_tolerations != null ~}
  tolerations: &MOJALOOP_TOLERATIONS
    ${indent(4, mojaloop_tolerations)}
%{ else ~}
  tolerations: &MOJALOOP_TOLERATIONS []
%{ endif ~}

%{ if mojaloop_fx_enabled ~}
  ml_api_adapter_image: &ML_API_ADAPTER_IMAGE
    registry: docker.io
    repository: mojaloop/ml-api-adapter
    tag: v14.1.0-snapshot.5

  cl_image: &CL_IMAGE
    registry: docker.io
    repository: mojaloop/central-ledger
    tag: v17.7.0-snapshot.0

  qs_image: &QS_IMAGE
    registry: docker.io
    repository: mojaloop/quoting-service
    tag: v15.8.0-snapshot.15
%{ else ~}
  ml_api_adapter_image: &ML_API_ADAPTER_IMAGE {}
  cl_image: &CL_IMAGE {}
  qs_image: &QS_IMAGE {}
%{ endif ~}

global:
  config:
    forensicloggingsidecar_disabled: true

account-lookup-service:
  account-lookup-service:
    commonAnnotations:
      secret.reloader.stakater.com/reload: "${jws_key_secret}"
%{ if account_lookup_service_affinity != null ~}
    affinity:
      ${indent(8, account_lookup_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${account_lookup_service_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *ALS_DB_PASSWORD
      db_secret: *ALS_DB_SECRET
      db_host: *ALS_DB_HOST
      db_user: *ALS_DB_USER
      db_port: *ALS_DB_PORT
      db_database: *ALS_DB_DATABASE
      endpointSecurity: *ENDPOINT_SECURITY
    # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
      central_shared_end_point_cache:
        expiresIn: 180000
        generateTimeout: 30000
        getDecoratedValue: true
      central_shared_participant_cache:
        expiresIn: 61000
        generateTimeout: 30000
        getDecoratedValue: true
      general_cache:
        enabled: true
        maxByteSize: 10000000
        expiresIn: 61000
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: account-lookup-service.${ingress_subdomain}
    metrics:
      config:
        prefix: *ALS_MONITORING_PREFIX
  account-lookup-service-admin:
%{ if account_lookup_admin_service_affinity != null ~}
    affinity:
      ${indent(8, account_lookup_admin_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${account_lookup_service_admin_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *ALS_DB_PASSWORD
      db_secret: *ALS_DB_SECRET
      db_host: *ALS_DB_HOST
      db_user: *ALS_DB_USER
      db_port: *ALS_DB_PORT
      db_database: *ALS_DB_DATABASE
      endpointSecurity: *ENDPOINT_SECURITY
    # Thirdparty API Config
      featureEnableExtendedPartyIdType: ${mojaloop_thirdparty_support_enabled}
      central_shared_end_point_cache:
        expiresIn: 180000
        generateTimeout: 30000
        getDecoratedValue: true
      central_shared_participant_cache:
        expiresIn: 61000
        generateTimeout: 30000
        getDecoratedValue: true
      general_cache:
        enabled: true
        maxByteSize: 10000000
        expiresIn: 61000
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: account-lookup-service-admin.${ingress_subdomain}
    metrics:
      config:
        prefix: *ALS_MONITORING_PREFIX
  als-oracle-pathfinder:
    enabled: false

quoting-service:
  quoting-service:
    image: *QS_IMAGE
    commonAnnotations:
      secret.reloader.stakater.com/reload: "${jws_key_secret}"
%{ if quoting_service_affinity != null ~}
    affinity:
      ${indent(6, quoting_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${quoting_service_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      kafka_producer_quote_post_topic: 'topic-quotes-post'
      log_transport: "console"
      log_level: "info"
      db_password: *QUOTING_DB_PASSWORD
      db_secret: *QUOTING_DB_SECRET
      db_host: *QUOTING_DB_HOST
      db_user: *QUOTING_DB_USER
      db_port: *QUOTING_DB_PORT
      db_database: *QUOTING_DB_DATABASE
      endpointSecurity: *ENDPOINT_SECURITY
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: quoting-service.${ingress_subdomain}
    metrics:
      config:
        prefix: *QUOTING_MONITORING_PREFIX
  quoting-service-handler:
    image: *QS_IMAGE
    commonAnnotations:
      secret.reloader.stakater.com/reload: "${jws_key_secret}"
%{ if quoting_service_affinity != null ~}
    affinity:
      ${indent(6, quoting_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${quoting_service_handler_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      simple_routing_mode_enabled: ${quoting_service_simple_routing_mode_enabled}
      log_transport: "console"
      log_level: "info"
      db_password: *QUOTING_DB_PASSWORD
      db_secret: *QUOTING_DB_SECRET
      db_host: *QUOTING_DB_HOST
      db_user: *QUOTING_DB_USER
      db_port: *QUOTING_DB_PORT
      db_database: *QUOTING_DB_DATABASE
      endpointSecurity: *ENDPOINT_SECURITY
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: quoting-service-handler.${ingress_subdomain}
    metrics:
      config:
        prefix: *QUOTING_MONITORING_PREFIX

ml-api-adapter:
  ml-api-adapter-service:
    image: *ML_API_ADAPTER_IMAGE
%{ if ml_api_adapter_service_affinity != null ~}
    affinity:
      ${indent(8, ml_api_adapter_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${ml_api_adapter_service_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      #annotations:
        #nginx.ingress.kubernetes.io/rewrite-target: /$2
      hostname: ml-api-adapter.${ingress_subdomain}
    metrics:
      config:
        prefix: *ML_API_ADAPTER_MONITORING_PREFIX
  ml-api-adapter-handler-notification:
    image: *ML_API_ADAPTER_IMAGE
    commonAnnotations:
      secret.reloader.stakater.com/reload: "${jws_key_secret}"
%{ if ml_api_adapter_handler_notifications_affinity != null ~}
    affinity:
      ${indent(8, ml_api_adapter_handler_notifications_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${ml_api_adapter_handler_notifications_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      endpointSecurity: *ENDPOINT_SECURITY
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: ml-api-adapter-handler-notification.${ingress_subdomain}
    metrics:
      config:
        prefix: *ML_API_ADAPTER_MONITORING_PREFIX

centralledger:
  centralledger-service:
    image: *CL_IMAGE
%{ if centralledger_service_affinity != null ~}
    affinity:
      ${indent(8, centralledger_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_service_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /$2
      path: /admin(/|$)(.*)
      hostname: interop-switch.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-transfer-prepare:
    image: *CL_IMAGE
%{ if central_ledger_handler_transfer_prepare_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_transfer_prepare_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_transfer_prepare_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
      batch_processing_enabled: *CL_BATCH_PROCESSING_ENABLED
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-prepare.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-transfer-position:
    image: *CL_IMAGE
%{ if central_ledger_handler_transfer_position_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_transfer_position_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_transfer_position_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-position.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-transfer-position-batch:
    enabled: *CL_BATCH_PROCESSING_ENABLED
    image: *CL_IMAGE
%{ if central_ledger_handler_transfer_position_batch_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_transfer_position_batch_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_transfer_position_batch_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
      batch_size: ${central_ledger_handler_transfer_position_batch_size}
      batch_consume_timeout_in_ms: ${central_ledger_handler_transfer_position_batch_consume_timeout_ms}
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-position-batch.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-transfer-get:
    image: *CL_IMAGE
%{ if central_ledger_handler_transfer_get_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_transfer_get_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_transfer_get_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-get.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-transfer-fulfil:
    image: *CL_IMAGE
%{ if central_ledger_handler_transfer_fulfil_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_transfer_fulfil_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_transfer_fulfil_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
      batch_processing_enabled: *CL_BATCH_PROCESSING_ENABLED
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-transfer-fulfil.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-timeout:
    image: *CL_IMAGE
    tolerations: *MOJALOOP_TOLERATIONS
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-timeout.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
  centralledger-handler-admin-transfer:
    image: *CL_IMAGE
%{ if central_ledger_handler_admin_transfer_affinity != null ~}
    affinity:
      ${indent(8, central_ledger_handler_admin_transfer_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_ledger_handler_admin_transfer_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CL_DB_PASSWORD
      db_secret: *CL_DB_SECRET
      db_host: *CL_DB_HOST
      db_user: *CL_DB_USER
      db_port: *CL_DB_PORT
      db_database: *CL_DB_DATABASE
      cache_enabled: *CL_CACHE_ENABLED
      cache_expires_in_ms: *CL_CACHE_EXPIRES_IN_MS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hostname: central-ledger-admin-transfer.${ingress_subdomain}
    metrics:
      config:
        prefix: *CL_MONITORING_PREFIX
centralsettlement:
  centralsettlement-service:
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      annotations:
        nginx.ingress.kubernetes.io/rewrite-target: /v2/$2
      path: /settlements(/|$)(.*)
      hostname: interop-switch.${ingress_subdomain}
%{ if central_settlement_service_affinity != null ~}
    affinity:
      ${indent(8, central_settlement_service_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_settlement_service_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-deferredsettlement:
%{ if central_settlement_handler_deferredsettlement_affinity != null ~}
    affinity:
      ${indent(8, central_settlement_handler_deferredsettlement_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_settlement_handler_deferredsettlement_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-grosssettlement:
%{ if central_settlement_handler_grosssettlement_affinity != null ~}
    affinity:
      ${indent(8, central_settlement_handler_grosssettlement_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_settlement_handler_grosssettlement_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT
      db_database: *CS_DB_DATABASE
  centralsettlement-handler-rules:
%{ if central_settlement_handler_rules_affinity != null ~}
    affinity:
      ${indent(8, central_settlement_handler_rules_affinity)}
%{ endif ~}
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${central_settlement_handler_rules_replica_count}
    config:
      kafka_host: *KAFKA_HOST
      kafka_port: *KAFKA_PORT
      db_password: *CS_DB_PASSWORD
      db_secret: *CS_DB_SECRET
      db_host: *CS_DB_HOST
      db_user: *CS_DB_USER
      db_port: *CS_DB_PORT
      db_database: *CS_DB_DATABASE

transaction-requests-service:
  podLabels:
    sidecar.istio.io/inject: "${enable_istio_injection}"
%{ if trasaction_requests_service_affinity != null ~}
  affinity:
    ${indent(8, trasaction_requests_service_affinity)}
%{ endif ~}
  tolerations: *MOJALOOP_TOLERATIONS
  replicaCount: ${trasaction_requests_service_replica_count}
  ingress:
%{ if istio_create_ingress_gateways ~}
    enabled: false
%{ else ~}
    enabled: true
%{ endif ~}
    className: *INGRESS_CLASS
    hostname: transaction-request-service.${ingress_subdomain}

thirdparty:
  enabled: ${mojaloop_thirdparty_support_enabled}
  auth-svc:
    enabled: true
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${auth_service_replica_count}
    config:
      db_host: *TP_AUTH_SVC_DB_HOST
      db_port: *TP_AUTH_SVC_DB_PORT
      db_user: *TP_AUTH_SVC_DB_USER
      db_password: *TP_AUTH_SVC_DB_PASSWORD
      db_secret: *TP_AUTH_SVC_DB_SECRET
      db_database: *TP_AUTH_SVC_DB_DATABASE
      redis_host: *TP_AUTH_SVC_REDIS_HOST
      redis_port: *TP_AUTH_SVC_REDIS_PORT
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      hostname: auth-service.upgtest.${ingress_subdomain}
      className: *INGRESS_CLASS

  consent-oracle:
    enabled: true
    tolerations: *MOJALOOP_TOLERATIONS
    replicaCount: ${consent_oracle_replica_count}
    config:
      db_host: *TP_ALS_CONSENT_SVC_DB_HOST
      db_port: *TP_ALS_CONSENT_SVC_DB_PORT
      db_user: *TP_ALS_CONSENT_SVC_DB_USER
      db_password: *TP_ALS_CONSENT_SVC_DB_PASSWORD
      db_secret: *TP_ALS_CONSENT_SVC_DB_SECRET
      db_database: *TP_ALS_CONSENT_SVC_DB_DATABASE
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      hostname: consent-oracle.upgtest.${ingress_subdomain}
      className: *INGRESS_CLASS

  tp-api-svc:
    enabled: true
    tolerations: *MOJALOOP_TOLERATIONS
    podLabels:
      sidecar.istio.io/inject: "${enable_istio_injection}"
    replicaCount: ${tp_api_svc_replica_count}
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      hostname: tp-api-svc.upgtest.${ingress_subdomain}
      className: *INGRESS_CLASS

  thirdparty-simulator:
    enabled: true
    tolerations: *MOJALOOP_TOLERATIONS

simulator:
  tolerations: *MOJALOOP_TOLERATIONS
  ingress:
%{ if istio_create_ingress_gateways ~}
    enabled: false
%{ else ~}
    enabled: true
%{ endif ~}
    className: *INGRESS_CLASS
    hostname: moja-simulator.${ingress_subdomain}

mojaloop-bulk:
  enabled: ${bulk_enabled}
  bulk-api-adapter:
    bulk-api-adapter-service:
      tolerations: *MOJALOOP_TOLERATIONS
      replicaCount: ${bulk_api-adapter_service_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
      ingress:
%{ if istio_create_ingress_gateways ~}
        enabled: false
%{ else ~}
        enabled: true
%{ endif ~}
        className: *INGRESS_CLASS
        hostname: bulk-api-adapter.${ingress_subdomain}
    bulk-api-adapter-handler-notification:
      commonAnnotations:
        secret.reloader.stakater.com/reload: "${jws_key_secret}"
      tolerations: *MOJALOOP_TOLERATIONS
      podLabels:
        sidecar.istio.io/inject: "${enable_istio_injection}"
      replicaCount: ${bulk_api_adapter_handler_notification_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
        endpointSecurity: *ENDPOINT_SECURITY
  bulk-centralledger:
    cl-handler-bulk-transfer-prepare:
      tolerations: *MOJALOOP_TOLERATIONS
      replicaCount: ${cl_handler_bulk_transfer_prepare_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-fulfil:
      tolerations: *MOJALOOP_TOLERATIONS
      replicaCount: ${cl_handler_bulk_transfer_fulfil_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-processing:
      tolerations: *MOJALOOP_TOLERATIONS
      replicaCount: ${cl_handler_bulk_transfer_processing_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE
    cl-handler-bulk-transfer-get:
      tolerations: *MOJALOOP_TOLERATIONS
      replicaCount: ${cl_handler_bulk_transfer_get_replica_count}
      config:
        kafka_host: *KAFKA_HOST
        kafka_port: *KAFKA_PORT
        db_password: *CL_DB_PASSWORD
        db_secret: *CL_DB_SECRET
        db_host: *CL_DB_HOST
        db_user: *CL_DB_USER
        db_port: *CL_DB_PORT
        db_database: *CL_DB_DATABASE
        mongo_host: *OBJSTORE_MONGO_HOST
        mongo_port: *OBJSTORE_MONGO_PORT
        mongo_user: *OBJSTORE_MONGO_USER
        mongo_password: *OBJSTORE_MONGO_PASSWORD
        mongo_secret: *OBJSTORE_MONGO_SECRET
        mongo_database: *OBJSTORE_MONGO_DATABASE

mojaloop-ttk-simulators:
  enabled: ${ttksims_enabled}

  mojaloop-ttk-sim1-svc:
    enabled: true
    sdk-scheme-adapter: &MOJA_TTK_SIM_SDK
      sdk-scheme-adapter-api-svc:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

      sdk-scheme-adapter-dom-evt-handler:
        tolerations: *MOJALOOP_TOLERATIONS
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

      sdk-scheme-adapter-cmd-evt-handler:
        tolerations: *MOJALOOP_TOLERATIONS
        kafka:
          host: *MOJA_TTK_SIM_KAFKA_HOST
          port: *MOJA_TTK_SIM_KAFKA_PORT

        redis:
          host: *MOJA_TTK_SIM_REDIS_HOST
          port: *MOJA_TTK_SIM_REDIS_PORT

    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            specApi:
              host: ttksim1-specapi.${ingress_subdomain}
            adminApi:
              host: ttksim1.${ingress_subdomain}

        extraEnvironments:
          hub-k8s-default-environment.json: &ttksim1InputValues {
            "inputValues": {
              "TTKSIM1_CURRENCY": "${ttk_test_currency1}",
              "TTKSIM2_CURRENCY": "${ttk_test_currency1}",
              "TTKSIM3_CURRENCY": "${ttk_test_currency1}",
              "TTKSIM1_FSPID": "ttksim1",
              "TTKSIM2_FSPID": "ttksim2",
              "TTKSIM3_FSPID": "ttksim3"
            }
          }
        config:
          mongodb:
            host: *TTK_MONGO_HOST
            port: *TTK_MONGO_PORT
            user: *TTK_MONGO_USER
            ## Secret-Management
            ### Set this if you are using a clear password configured in the config section
            password: *TTK_MONGO_PASSWORD
            ### Configure this if you want to use a secret. Note, this will override the db_password,
            ### Use the next line if you do wish to use the db_password value instead.
            # secret:
            ### Example config for an existing secret
            secret: *TTK_MONGO_SECRET
            database: *TTK_MONGO_DATABASE

      ml-testing-toolkit-frontend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            ui:
              host: ttksim1.${ingress_subdomain}
        config:
          API_BASE_URL: http://ttksim1.${ingress_subdomain}

  mojaloop-ttk-sim2-svc:
    enabled: true
    sdk-scheme-adapter: *MOJA_TTK_SIM_SDK
    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            specApi:
              host: ttksim2-specapi.${ingress_subdomain}
            adminApi:
              host: ttksim2.${ingress_subdomain}

      ml-testing-toolkit-frontend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            ui:
              host: ttksim2.${ingress_subdomain}
        config:
          API_BASE_URL: http://ttksim2.${ingress_subdomain}

  mojaloop-ttk-sim3-svc:
    enabled: true
    sdk-scheme-adapter: *MOJA_TTK_SIM_SDK
    ml-testing-toolkit:
      ml-testing-toolkit-backend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            specApi:
              host: ttksim3-specapi.${ingress_subdomain}
            adminApi:
              host: ttksim3.${ingress_subdomain}

      ml-testing-toolkit-frontend:
        tolerations: *MOJALOOP_TOLERATIONS
        ingress:
          enabled: false
          hosts:
            ui:
              host: ttksim3.${ingress_subdomain}
        config:
          API_BASE_URL: http://ttksim3.${ingress_subdomain}

ml-testing-toolkit:
  enabled: ${internal_ttk_enabled}
  ml-testing-toolkit-backend:
    tolerations: *MOJALOOP_TOLERATIONS
    config:
      mongodb:
        host: *TTK_MONGO_HOST
        port: *TTK_MONGO_PORT
        user: *TTK_MONGO_USER
        password: *TTK_MONGO_PASSWORD
        secret: *TTK_MONGO_SECRET
        database: *TTK_MONGO_DATABASE
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hosts:
        specApi:
          host: ${ttk_backend_public_fqdn}
        adminApi:
          host: ${ttk_backend_public_fqdn}
    parameters: &simNames
      simNamePayerfsp: 'payerfsp'
      simNamePayeefsp: 'payeefsp'
      simNameTestfsp1: 'testfsp1'
      simNameTestfsp2: 'testfsp2'
      simNameTestfsp3: 'testfsp3'
      simNameTestfsp4: 'testfsp4'
      simNameNoResponsePayeefsp: 'noresponsepayeefsp'
      simNameTTKSim1: 'ttksim1'
      simNameTTKSim2: 'ttksim2'
      simNameTTKSim3: 'ttksim3'
    extraEnvironments:
      hub-k8s-cgs-environment.json: null
      hub-k8s-default-environment.json: &ttkInputValues {
        "inputValues": {
          "SIMPAYER_CURRENCY": "${ttk_test_currency1}",
          "SIMPAYEE_CURRENCY": "${ttk_test_currency1}",
          "currency": "${ttk_test_currency1}",
          "currency2": "${ttk_test_currency2}",
          "cgscurrency": "${ttk_test_currency3}",
          "SIMPLE_ROUTING_MODE_ENABLED": ${quoting_service_simple_routing_mode_enabled},
          "ON_US_TRANSFERS_ENABLED": false,
          "ENABLE_WS_ASSERTIONS": true,
          "NET_DEBIT_CAP": "10000000",
          "accept": "application/vnd.interoperability.parties+json;version=1.1",
          "acceptParties": "application/vnd.interoperability.parties+json;version=1.1",
          "acceptPartiesOld": "application/vnd.interoperability.parties+json;version=1.0",
          "acceptPartiesNotSupported": "application/vnd.interoperability.parties+json;version=2.0",
          "acceptParticipants": "application/vnd.interoperability.participants+json;version=1.1",
          "acceptParticipantsOld": "application/vnd.interoperability.participants+json;version=1.0",
          "acceptParticipantsNotSupported": "application/vnd.interoperability.participants+json;version=2.0",
          "acceptQuotes": "application/vnd.interoperability.quotes+json;version=1.1",
          "acceptQuotesOld": "application/vnd.interoperability.quotes+json;version=1.0",
          "acceptQuotesNotSupported": "application/vnd.interoperability.quotes+json;version=2.0",
          "acceptTransfers": "application/vnd.interoperability.transfers+json;version=1.1",
          "acceptTransfersOld": "application/vnd.interoperability.transfers+json;version=1.0",
          "acceptTransfersNotSupported": "application/vnd.interoperability.transfers+json;version=2.0",
          "acceptTransactionRequests": "application/vnd.interoperability.transactionRequests+json;version=1.1",
          "acceptTransactionRequestsOld": "application/vnd.interoperability.transactionRequests+json;version=1.0",
          "acceptTransactionRequestsNotSupported": "application/vnd.interoperability.transactionRequests+json;version=2.0",
          "acceptAuthorizations": "application/vnd.interoperability.authorizations+json;version=1.1",
          "acceptAuthorizationsOld": "application/vnd.interoperability.authorizations+json;version=1.0",
          "acceptAuthorizationsNotSupported": "application/vnd.interoperability.authorizations+json;version=2.0",
          "acceptBulkTransfers": "application/vnd.interoperability.bulkTransfers+json;version=1.1",
          "acceptBulkTransfersOld": "application/vnd.interoperability.bulkTransfers+json;version=1.0",
          "acceptBulkTransfersNotSupported": "application/vnd.interoperability.bulkTransfers+json;version=2.0",
          "contentType": "application/vnd.interoperability.parties+json;version=1.1",
          "contentTypeTransfers": "application/vnd.interoperability.transfers+json;version=1.1",
          "contentTypeTransfersOld": "application/vnd.interoperability.transfers+json;version=1.0",
          "contentTypeTransfersNotSupported": "application/vnd.interoperability.transfers+json;version=2.0",
          "contentTypeParties": "application/vnd.interoperability.parties+json;version=1.1",
          "contentTypePartiesOld": "application/vnd.interoperability.parties+json;version=1.0",
          "contentTypePartiesNotSupported": "application/vnd.interoperability.parties+json;version=2.0",
          "contentTypeParticipants": "application/vnd.interoperability.participants+json;version=1.1",
          "contentTypeParticipantsOld": "application/vnd.interoperability.participants+json;version=1.0",
          "contentTypeParticipantsNotSupported": "application/vnd.interoperability.participants+json;version=2.0",
          "contentTypeQuotes": "application/vnd.interoperability.quotes+json;version=1.1",
          "contentTypeQuotesOld": "application/vnd.interoperability.quotes+json;version=1.0",
          "contentTypeQuotesNotSupported": "application/vnd.interoperability.quotes+json;version=2.0",
          "contentTypeTransactionRequests": "application/vnd.interoperability.transactionRequests+json;version=1.1",
          "contentTypeTransactionRequestsOld": "application/vnd.interoperability.transactionRequests+json;version=1.0",
          "contentTypeTransactionRequestsNotSupported": "application/vnd.interoperability.transactionRequests+json;version=2.0",
          "contentTypeAuthorizations": "application/vnd.interoperability.authorizations+json;version=1.1",
          "contentTypeAuthorizationsOld": "application/vnd.interoperability.authorizations+json;version=1.0",
          "contentTypeAuthorizationsNotSupported": "application/vnd.interoperability.authorizations+json;version=2.0",
          "contentBulkTransfers": "application/vnd.interoperability.bulkTransfers+json;version=1.1",
          "contentBulkTransfersOld": "application/vnd.interoperability.bulkTransfers+json;version=1.0",
          "contentBulkTransfersNotSupported": "application/vnd.interoperability.bulkTransfers+json;version=2.0",
          "expectedPartiesVersion": "1.1",
          "expectedParticipantsVersion": "1.1",
          "expectedQuotesVersion": "1.1",
          "expectedTransfersVersion": "1.1",
          "expectedAuthorizationsVersion": "1.1",
          "expectedTransactionRequestsVersion": "1.1"
        }
      }

  ml-testing-toolkit-frontend:
    tolerations: *MOJALOOP_TOLERATIONS
    ingress:
%{ if istio_create_ingress_gateways ~}
      enabled: false
%{ else ~}
      enabled: true
%{ endif ~}
      className: *INGRESS_CLASS
      hosts:
        ui:
          host: ${ttk_frontend_public_fqdn}
          port: 6060
          paths: ['/']
    config:
      API_BASE_URL: https://${ttk_backend_public_fqdn}

ml-ttk-test-setup:
  tests:
    enabled: true
  config:
    testSuiteName: Provisioning
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues
  job:
    enabled: true
    templateLabels:
      sidecar.istio.io/inject: "false"
    ## Set the TTL for Job Cleanup - ref: https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/
    # ttlSecondsAfterFinished: 50
    generateNameEnabled: false
    annotations:
      argocd.argoproj.io/hook: PostSync

ml-ttk-test-val-gp:
  configFileDefaults:
    labels: ${ttk_gp_testcase_labels}
  tests:
    enabled: true
  config:
    testSuiteName: GP Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues
  job:
    enabled: true
    templateLabels:
      sidecar.istio.io/inject: "false"
    ## Set the TTL for Job Cleanup - ref: https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/
    # ttlSecondsAfterFinished: 50
    generateNameEnabled: false
    annotations:
      argocd.argoproj.io/hook: PostSync
      argocd.argoproj.io/sync-wave: "${mojaloop_test_sync_wave}"

ml-ttk-test-val-bulk:
  tests:
    enabled: true
  config:
    testSuiteName: Bulk Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

ml-ttk-test-setup-tp:
  tests:
    enabled: true
  config:
    testSuiteName: Third Party Provisioning Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

ml-ttk-test-val-tp:
  tests:
    enabled: true
  config:
    testSuiteName: Third Party Validation Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

ml-ttk-test-setup-sdk-bulk:
  tests:
    enabled: true
  config:
    testSuiteName: SDK Bulk Provisioning Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

ml-ttk-test-val-sdk-bulk:
  tests:
    enabled: true
  config:
    testSuiteName: SDK Bulk Validation Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://ttksim1.${ingress_subdomain}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttksim1InputValues

ml-ttk-test-val-sdk-r2p:
  tests:
    enabled: true
  config:
    testSuiteName: SDK Request To Pay Tests
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://ttksim1.${ingress_subdomain}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttksim1InputValues

ml-ttk-test-cleanup:
  tests:
    enabled: true
  config:
    testSuiteName: Post Cleanup
    environmentName: ${ingress_subdomain}
    saveReport: true
    saveReportBaseUrl: http://${ttk_backend_public_fqdn}
  parameters:
    <<: *simNames
  testCaseEnvironmentFile:  *ttkInputValues

mojaloop-simulator:
  enabled: ${internal_sim_enabled}
  defaults:
    tolerations: *MOJALOOP_TOLERATIONS
