apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- pinniped-oidc.yaml
helmCharts:
- name: reflector
  releaseName: reflector
  version: ${reflector_chart_version}
  repo: https://emberstack.github.io/helm-charts
  valuesFile: values-reflector.yaml
  namespace: ${base_utils_namespace}
- name: reloader
  releaseName: reloader
  version: ${reloader_chart_version}
  repo: https://stakater.github.io/stakater-charts
  valuesFile: values-reloader.yaml
  namespace: ${base_utils_namespace}
- name: pinniped
  releaseName: pinniped
  version: ${pinniped_chart_version}
  repo: https://charts.bitnami.com/bitnami
  valuesFile: values-pinniped.yaml
  namespace: ${pinniped_namespace}