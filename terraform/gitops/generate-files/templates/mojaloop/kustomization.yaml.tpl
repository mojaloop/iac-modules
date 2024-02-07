apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ext-ingress.yaml
  - grafana.yaml
  - istio-config.yaml
  - service-monitors.yaml
  - vault-secret.yaml
  - rbac.yaml
  #add role/permissions folder
helmCharts:
- name: mojaloop
  releaseName: ${mojaloop_release_name}
  version: ${mojaloop_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-mojaloop.yaml
  namespace: ${mojaloop_namespace}
- name: finance-portal
  releaseName: ${finance_portal_release_name}
  version: ${finance_portal_chart_version}
  repo: https://mojaloop.github.io/charts/repo
  valuesFile: values-finance-portal.yaml
  namespace: ${mojaloop_namespace}
  includeCRDs: true
- name: reporting-k8s-templates
  releaseName: reporting-templates
  version: ${reporting_templates_chart_version}
  repo: https://mojaloop.github.io/reporting-k8s-templates
  namespace: ${mojaloop_namespace}
  includeCRDs: false