global:
  keto:
    readURL: "http://keto-read:80"
    writeURL: "http://keto-write:80"

  mojalooprole: {}
  rolePermOperator:
    mojaloopRole: {}
    mojaloopPermissionExclusion: {}
    apiSvc: {}

## RBAC Tests
rbacTests:
  enabled: true
  command:
    - npm
    - run
    - test:rbac
    - --
    - --silent=false
  env:
    ROLE_ASSIGNMENT_SVC_BASE_PATH: http://${bof_release_name}-role-assignment-service
    ML_INGRESS_BASE_PATH: https://${auth_fqdn}
    TEST_USER_NAME: ${test_user_name}
    TEST_USER_PASSWORD: ${test_user_password}



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
          "audit"
        ]
      }

reporting-hub-bop-api-svc:
  enabled: true
  ingress:
    enabled: false

reporting-legacy-api:
  enabled: true
  ingress:
    enabled: false
  install-templates: true
  auth: true
  config:
    env:
      VALIDATION_RETRY_COUNT: "10"
      VALIDATION_RETRY_INTERVAL_MS: "5000"
  reporting-k8s-templates:
    templates:
      settlement: true,
      dfspSettlement: true,
      dfspSettlementDetail: true,
      reconciliationAmount: true,
      settlementWindow: true,
      settlementInitiation: true,
      transactionReconciliation: true,
      dfspSettlementStatement: true,
      settlementAudit: true


security-hub-bop-kratos-ui:
  enabled: false

### Micro-frontends
reporting-hub-bop-role-ui:
  enabled: true
  ingress:
    enabled: false
  config:
    env:
      REACT_APP_API_BASE_URL: https://${auth_fqdn}/proxy/iam
      REACT_APP_MOCK_API: false


reporting-hub-bop-trx-ui:
  enabled: true
  ingress:
    enabled: false
  config:
    env:
      REACT_APP_API_BASE_URL: https://${auth_fqdn}/proxy/transfers
      REACT_APP_MOCK_API: false



reporting-hub-bop-positions-ui:
  enabled: true
  config:
    env:
      CENTRAL_LEDGER_ENDPOINT: https://${auth_fqdn}/proxy/central-admin
  ingress:
    enabled: false

security-role-perm-operator-svc:
  enabled: true
  ingress:
    enabled: false
    


reporting-hub-bop-experience-api-svc:
  enabled: true
