apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ext-ingress.yaml
  - grafana.yaml
  - istio-config.yaml
  - service-monitors.yaml
  - oathkeeper-rules/central-admin.yaml
  - oathkeeper-rules/central-settlements.yaml
  - oathkeeper-rules/iam.yaml
  - oathkeeper-rules/reports.yaml
  - oathkeeper-rules/transfers.yaml
helmCharts:
- name: mojaloop
  releaseName: ${mojaloop_release_name}
  version: ${mojaloop_chart_version}
  repo: ${mojaloop_chart_repo}
  valuesFile: values-mojaloop.yaml
  namespace: ${mojaloop_namespace}
# - name: bof
#   releaseName: ${bof_release_name}
#   version: ${bof_chart_version}
#   repo: https://mojaloop.github.io/charts/repo
#   valuesFile: values-bof.yaml
#   namespace: ${mojaloop_namespace}