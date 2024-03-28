# Custom YAML TEMPLATE Anchors
CONFIG:
  ## KAFKA BACKEND
  kafka_url: &KAFKA_URL "${kafka_host}:${kafka_port}"
  redis_host: &REDIS_HOST "${redis_host}"
  redis_port: &REDIS_PORT ${redis_port}
  mongo_url_secret_name: &MONGO_URL_SECRET_NAME "${vnext_mongo_url_secret_name}"
  mongo_url_secret_key: &MONGO_URL_SECRET_KEY "url"
  platform_config_base_svc_url: &PLATFORM_CONFIG_BASE_SVC_URL http://${vnext_release_name}-platform-configuration-svc:3100
  auth_z_svc_baseurl: &AUTH_Z_SVC_BASEURL http://${vnext_release_name}-authorization-svc:3202
  auth_n_svc_baseurl: &AUTH_N_SVC_BASEURL http://${vnext_release_name}-authentication-svc:3201
  participants_svc_url: &PARTICIPANTS_SVC_URL http://${vnext_release_name}-participants-svc:3010
  elasticsearch_url: &ELASTICSEARCH_URL http://elasticsearch.monitoring.svc.cluster.local:9200
  builtin_ledger_svc_url: &BUILTIN_LEDGER_SVC_URL ${vnext_release_name}-accounts-and-balances-builtin-ledger-grpc-svc:3350
  account_and_balance_coa_svc: &ACCOUNT_AND_BALANCE_COA_SVC ${vnext_release_name}-accounts-and-balances-coa-grpc-svc:3300
  settlements_svc_url: &SETTLEMENTS_SVC_URL http://${vnext_release_name}-settlements-api-svc:3600

  ## Endpiont Security
  endpointSecurity: &ENDPOINT_SECURITY
    jwsSigningKeySecret: &JWS_SIGNING_KEY_SECRET
      name: ${jws_key_secret}
      key: ${jws_key_secret_private_key_key}


account-lookup-http-oracle-svc:
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

account-lookup-svc:
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

accounts-and-balances-builtin-ledger-grpc-svc:
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

accounts-and-balances-coa-grpc-svc:
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

admin-ui:
  enabled: true
  ingress:
    enabled: false
  nginx:
    config: |-
          server {
              listen       4200;
              server_name  localhost;

              location / {
                  root   /usr/share/nginx/html;
                  index  index.html;
                  try_files $uri$args $uri$args/ /index.html;
              }

            # proxy for rest apis - should match angular dev proxy.conf.json
              location /auth_n {
                rewrite /auth_n/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-authentication-svc:3201;
            }

              location /auth_z {
                rewrite /auth_z/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-authorization-svc:3202;
            }

            location /_participants {
              rewrite /_participants/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-participants-svc:3010;
            }

              location /_platform-configuration-svc {
                rewrite /_platform-configuration-svc/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-platform-configuration-svc:3100;
            }

              location /_account-lookup {
                rewrite /_account-lookup/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-account-lookup-svc:3030;
            }

              location /_interop {
                rewrite /_interop/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-fspiop-api-svc:4000;
            }

            location /_quotes {
              rewrite /_quotes/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-quoting-svc:3033;
            }

              location /_bulk-quotes {
                rewrite /_bulk-quotes/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-quoting-svc:3033;
            }

              location /_transfers {
              rewrite /_transfers/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-transfers-api-svc:3500;
            }

            location /_settlements {
              rewrite /_settlements/(.*) /$1  break;
              proxy_pass http://${vnext_release_name}-settlements-api-svc:3600;
              proxy_http_version 1.1;
            }

              error_page   500 502 503 504  /50x.html;
              location = /50x.html {
                  root   /usr/share/nginx/html;
              }
          }

auditing-svc:
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

authentication-svc:
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

authorization-svc:
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

fspiop-api-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

logging-svc:
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

participants-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL
  
platform-configuration-svc:
  enabled: true
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

quoting-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

settlements-api-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL
  
settlements-command-handler-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

settlements-event-handler-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

transfers-api-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL
  
transfers-command-handler-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL

transfers-event-handler-svc:
  enabled: true
  config:
    mongo_url_secret:
      name: *MONGO_URL_SECRET_NAME
      key: *MONGO_URL_SECRET_KEY
  ingress:
    enabled: false
  env:
    kafka_url: *KAFKA_URL
    redis_host: *REDIS_HOST
    redis_port: *REDIS_PORT
    mongo_url_secret_name: *MONGO_URL_SECRET_NAME
    mongo_url_secret_key: *MONGO_URL_SECRET_KEY
    platform_config_base_svc_url: *PLATFORM_CONFIG_BASE_SVC_URL
    auth_z_svc_baseurl: *AUTH_Z_SVC_BASEURL
    auth_n_svc_baseurl: *AUTH_N_SVC_BASEURL
    participants_svc_url: *PARTICIPANTS_SVC_URL
    elasticsearch_url: *ELASTICSEARCH_URL
    builtin_ledger_svc_url: *BUILTIN_LEDGER_SVC_URL
    account_and_balance_coa_svc: *ACCOUNT_AND_BALANCE_COA_SVC
    settlements_svc_url: *SETTLEMENTS_SVC_URL
