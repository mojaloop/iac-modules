global:
  keto:
    readURL: "http://keto-read:80"
    writeURL: "http://keto-write:80"
  wso2:
    identityServer:
      userListURL: "${wso2_host}/scim2/Users"
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
    hostname: ${api_fqdn}
    path: /iam(/|$)(.*)
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
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
    hostname: ${api_fqdn}
    path: /operator(/validate/.*)
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: $1
    tls: true
    selfSigned: true
    tlsSetSecretManual: true
    tlsManualSecretName: ""

