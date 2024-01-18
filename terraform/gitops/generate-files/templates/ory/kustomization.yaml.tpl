apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
- name: oathkeeper
  releaseName: oathkeeper
  version: ${oathkeeper_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-oathkeeper.yaml
- name: oathkeeper-maester
  releaseName: oathkeeper-maester
  version: ${oathkeeper_maester_chart_version}
  repo: https://k8s.ory.sh/helm/charts
  valuesFile: values-oathkeeper-maester.yaml
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