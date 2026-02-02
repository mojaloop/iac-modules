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
  testSuiteName: MCM RBAC Tests
  saveReport: true
  saveReportBaseUrl: https://${ttk_fqdn}
  reportName: mcm_rbac_tests
  allowFailures: false
  environmentName: ${public_subdomain}
script: |
    # Wait for DNS
    until nslookup github.com; do echo "Waiting for DNS..."; sleep 5; done

    # Download scripts
    echo "Downloading MCM test scripts..."
    MCM_SCRIPTS_BASE="https://raw.githubusercontent.com/mojaloop/connection-manager-api/${ttk_mcm_scripts_version}/scripts"
    wget "$${MCM_SCRIPTS_BASE}/mcm-test-setup" -O /tmp/mcm-test-setup
    wget "$${MCM_SCRIPTS_BASE}/mcm-rbac-test.sh" -O /tmp/mcm-rbac-test.sh
    chmod +x /tmp/mcm-test-setup /tmp/mcm-rbac-test.sh

    # Download test collections
    echo "Downloading test collections..."
    wget https://github.com/mojaloop/testing-toolkit-test-cases/archive/v${ttk_mcm_rbac_testcases_tag}.zip -O /tmp/test-collections.zip
    mkdir -p /tmp/test_cases
    unzip -d /tmp/test_cases -o /tmp/test-collections.zip

    export MCM_TEST_SETUP="/tmp/mcm-test-setup"
    export TEST_CASES_DIR="/tmp/test_cases/testing-toolkit-test-cases-${ttk_mcm_rbac_testcases_tag}/collections/hub/mcm"

    # Run MCM RBAC tests
    /tmp/mcm-rbac-test.sh
envSecret: ${portal_admin_secret}
env:
  NPM_CONFIG_UPDATE_NOTIFIER: "false"
  MCM_EXTERNAL_URL: https://${mcm_fqdn}
  KRATOS_PUBLIC_URL: http://kratos-public.${ory_namespace}.svc.cluster.local
  KRATOS_EXTERNAL_URL: https://${auth_fqdn}/kratos
  KEYCLOAK_URL: https://${keycloak_fqdn}
  KEYCLOAK_DFSP_REALM_NAME: ${keycloak_dfsp_realm_name}
  KEYCLOAK_HUBOP_REALM_NAME: ${keycloak_hubop_realm_name}
  MAILPIT_URL: http://mailpit-http.${mailpit_namespace}.svc.cluster.local:80
  PORTAL_ADMIN_USER: portal_admin
  TTK_BACKEND_URL: http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050
  SAVE_REPORT: "true"
  SAVE_REPORT_BASE_URL: https://${ttk_fqdn}
  ALLOW_FAILURES: "false"
configFileDefaults:
  mode: outbound
  logLevel: "2"
parameters: {}
testCaseEnvironmentFile:
  inputValues: {}
