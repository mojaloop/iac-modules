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
    user: '${role_assign_svc_user}'
    secret:
      name: '${role_assign_svc_secret}'
      key: '${vault_secret_key}'
    realm: '${keycloak_pm4ml_realm_name}'

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
          "pm4mladmin"
        ],
        "AUTO_GRANT_PORTAL_ADMIN_ROLES": [
          "manager"
        ]
      }

reporting-hub-bop-api-svc:
  enabled: false

reporting-legacy-api:
  enabled: false

reporting-events-processor-svc:
  enabled: false

reporting-hub-bop-experience-api-svc:
  enabled: false

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
      LOGIN_URL: https://${auth_fqdn}/kratos/self-service/login/browser
      ## client_id and post_logout_redirect_uri can be passed in return_url to redirect the user back to portal after logout
      ## Example: return_url=http%3A%2F%2F$${keycloak_fqdn}%2Frealms%2F$${keycloak_pm4ml_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout%3Fclient_id%3D$${hubop_oidc_client_id}%26post_logout_redirect_uri%3Dhttps%3A%2F%2F$${portal_fqdn}
      LOGOUT_URL: /kratos/self-service/logout/browser?return_to=https%3A%2F%2F${keycloak_fqdn}%2Frealms%2F${keycloak_pm4ml_realm_name}%2Fprotocol%2Fopenid-connect%2Flogout
      LOGIN_PROVIDER: ${keycloak_pm4ml_realm_name}
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
