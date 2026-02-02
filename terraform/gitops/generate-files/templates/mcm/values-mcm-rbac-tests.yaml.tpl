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
  mailpitUrl: http://mailpit-http.${mailpit_namespace}.svc.cluster.local:80
  portalAdminUser: portal_admin
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

    # Export environment variables for mcm-rbac-test.sh and mcm-test-setup
    export MCM_TEST_SETUP="/tmp/mcm-test-setup"
    export MCM_EXTERNAL_URL="https://${mcm_fqdn}"
    export KRATOS_PUBLIC_URL="http://kratos-public.${ory_namespace}.svc.cluster.local"
    export KRATOS_EXTERNAL_URL="https://${auth_fqdn}/kratos"
    export KEYCLOAK_URL="https://${keycloak_fqdn}"
    export KEYCLOAK_FQDN="${keycloak_fqdn}"
    export KEYCLOAK_DFSP_REALM_NAME="${keycloak_dfsp_realm_name}"
    export KEYCLOAK_HUBOP_REALM_NAME="${keycloak_hubop_realm_name}"
    export MAILPIT_URL="http://mailpit-http.${mailpit_namespace}.svc.cluster.local:80"
    export PORTAL_ADMIN_USER="portal_admin"
    export PORTAL_ADMIN_PASSWORD="$${PORTAL_ADMIN_PASSWORD}"
    export TTK_BACKEND_URL="http://moja-ml-testing-toolkit-backend.${mojaloop_namespace}.svc.cluster.local:5050"
    export TEST_CASES_DIR="/tmp/test_cases/testing-toolkit-test-cases-${ttk_mcm_rbac_testcases_tag}/collections/hub/mcm"
    export SAVE_REPORT="true"
    export SAVE_REPORT_BASE_URL="https://${ttk_fqdn}"
    export ALLOW_FAILURES="false"

    # Run MCM RBAC tests
    /tmp/mcm-rbac-test.sh
envSecret: ${portal_admin_secret}
env:
  NPM_CONFIG_UPDATE_NOTIFIER: "false"
configFileDefaults:
  mode: outbound
  logLevel: "2"
parameters: {}
testCaseEnvironmentFile:
  inputValues: {}
