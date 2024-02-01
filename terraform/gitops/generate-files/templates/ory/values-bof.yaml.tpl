global:
  keto:
    readURL: "http://keto-read:80"
    writeURL: "http://keto-write:80"
  wso2:
    identityServer:
      userListURL: "/scim2/Users"
      user: 'admin'
      secret:
        name: wso2-is-admin-creds
        key: password
  rolePermOperator:
    mojaloopRole: {}
    mojaloopPermissionExclusion: {}
    apiSvc: {}
  ## Currently setting the following to dummy values and we need to remove this dependency
  adminApiSvc:
    host: "dummy"
    port: 80

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

security-role-perm-operator-svc:
  enabled: true
  ingress:
    enabled: false

