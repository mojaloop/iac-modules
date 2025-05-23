apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ext-ingress.yaml
  - grafana.yaml
  - istio-config.yaml
  - service-monitors.yaml
  - vault-secret.yaml
  - switch-jws-deployment.yaml
  - opentelemetry-instrumentation.yaml
  - rbac-api-resources.yaml
  - simulator-issuer.yaml
helmCharts:
- name: mojaloop
  releaseName: ${mojaloop_release_name}
  version: ${mojaloop_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-mojaloop.yaml
  namespace: ${mojaloop_namespace}
  additionalValuesFiles:
  - values-mojaloop-override.yaml
  - values-mojaloop-addons.yaml
- name: finance-portal
  releaseName: ${finance_portal_release_name}
  version: ${finance_portal_chart_version}
  repo: https://mojaloop.github.io/charts/repo
  valuesFile: values-finance-portal.yaml
  namespace: ${mojaloop_namespace}
  includeCRDs: true
  additionalValuesFiles:
  - values-finance-portal-override.yaml
- name: reporting-k8s-templates
  releaseName: reporting-templates
  version: ${reporting_templates_chart_version}
  repo: https://mojaloop.github.io/reporting-k8s-templates
  namespace: ${mojaloop_namespace}
  includeCRDs: false
- name: ml-testing-toolkit-cli
  releaseName: hub-provisioning
  version: ${ml_testing_toolkit_cli_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-hub-provisioning.yaml
  namespace: ${mojaloop_namespace}
  additionalValuesFiles:
  - values-hub-provisioning-override.yaml
