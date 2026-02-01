tests:
  enabled: true
  weight: 3
job:
  enabled: true
  generateNameEnabled: false
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/sync-wave: "1"
config:
  testCasesZipUrl: https://github.com/mojaloop/testing-toolkit-test-cases/archive/v${ttk_mcm_rbac_testcases_tag}.zip
  testCasesPathInZip: testing-toolkit-test-cases-${ttk_mcm_rbac_testcases_tag}/collections/hub/mcm
  ttkBackendURL: http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050
  testSuiteName: MCM RBAC Tests
  saveReport: true
  saveReportBaseUrl: https://${ttk_fqdn}
  reportName: mcm_rbac_tests
  allowFailures: false
  mcmScriptsVersion: ${ttk_mcm_scripts_version}
  mcmUrl: http://mcm-connection-manager-api.${mcm_namespace}.svc.cluster.local:3001
  kratosPublicUrl: http://kratos-public.${ory_namespace}.svc.cluster.local
  keycloakUrl: https://${keycloak_fqdn}
  keycloakRealm: ${keycloak_dfsp_realm_name}
  mailpitUrl: http://mailpit-http.${mailpit_namespace}.svc.cluster.local:8025
  portalAdminUser: portal_admin
  environmentName: ${public_subdomain}
env:
  NPM_CONFIG_UPDATE_NOTIFIER: "false"
configFileDefaults:
  mode: outbound
  logLevel: "2"
parameters: {}
testCaseEnvironmentFile:
  inputValues: {}
