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
  - report-bucket.yaml
helmCharts:
- name: mojaloop
  releaseName: ${mojaloop_release_name}
  version: ${mojaloop_helm_version}
  repo: ${mojaloop_helm_repo}
  valuesFile: values-mojaloop.yaml
  namespace: ${mojaloop_namespace}
  additionalValuesFiles:
  - values-mojaloop-override.yaml
  - values-mojaloop-addons.yaml
- name: finance-portal
  releaseName: ${finance_portal_release_name}
  version: ${finance_portal_chart_version}
  repo: ${mojaloop_charts_repo}
  valuesFile: values-finance-portal.yaml
  namespace: ${mojaloop_namespace}
  includeCRDs: true
  additionalValuesFiles:
  - values-finance-portal-override.yaml
- name: reporting-k8s-templates
  releaseName: reporting-templates
  version: ${reporting_templates_chart_version}
  repo: ${reporting_templates_chart_repo}
  namespace: ${mojaloop_namespace}
  includeCRDs: false
  additionalValuesFiles:
  - values-reporting-k8s-templates-override.yaml
- name: ml-testing-toolkit-cli
  releaseName: hub-provisioning
  version: ${ml_testing_toolkit_cli_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-hub-provisioning.yaml
  namespace: ${mojaloop_namespace}
  additionalValuesFiles:
  - values-hub-provisioning-override.yaml
patches:
  - target:
      kind: Service
    patch: |-
      - op: add
        path: /metadata/labels/istio.io~1ingress-use-waypoint
        value: 'true'
