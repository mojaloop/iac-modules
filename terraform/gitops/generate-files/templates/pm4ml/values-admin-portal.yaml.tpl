global:
  keto:
    readURL: ${keto_read_url}
    writeURL: ${keto_write_url}
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
          "pm4mladmin"
        ],
        "AUTO_GRANT_PORTAL_ADMIN_ROLES": [
          "pm4mladmin"
        ]
      }

reporting-hub-bop-api-svc:
  enabled: false

reporting-legacy-api:
  enabled: false

reporting-events-processor-svc:
  enabled: false

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
  enabled: false

reporting-hub-bop-settlements-ui:
  enabled: false

reporting-hub-bop-positions-ui:
  enabled: false
