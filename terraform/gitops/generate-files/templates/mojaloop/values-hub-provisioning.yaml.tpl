tests:
  enabled: true
configFileDefaults:
  labels: ${ttk_hub_provisioning_testcase_labels}
config:
  testCasesZipUrl: https://github.com/mojaloop/testing-toolkit-test-cases/archive/v${ttk_testcases_tag}.zip
  testCasesPathInZip: testing-toolkit-test-cases-${ttk_testcases_tag}/collections/hub/provisioning/new_hub
  testSuiteName: Hub Provisioning
  environmentName: ${ingress_subdomain}
  saveReport: true
  saveReportBaseUrl: http://${ttk_backend_fqdn}
testCaseEnvironmentFile:
  inputValues:
    HUB_NAME: ${hub_name}
    ## Currencies and other configuration will be provided by profiles / gitlab custom config
job:
  enabled: true
  templateLabels:
    sidecar.istio.io/inject: "false"
  generateNameEnabled: false
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/sync-wave: "${mojaloop_hub_provisioning_sync_wave}"

