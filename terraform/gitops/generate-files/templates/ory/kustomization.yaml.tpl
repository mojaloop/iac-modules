apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
  - keycloak-realm-cr.yaml
  - istio-config.yaml
helmCharts:
- name: oathkeeper
  releaseName: oathkeeper
  version: ${oathkeeper_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-oathkeeper.yaml
- name: kratos
  releaseName: kratos
  version: ${kratos_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-kratos.yaml
- name: keto
  releaseName: keto
  version: ${keto_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-keto.yaml