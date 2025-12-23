apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
helmCharts:
- name: reflector
  releaseName: reflector
  version: ${reflector_chart_version}
  repo: ${reflector_repo_url}
  valuesFile: values-reflector.yaml
  namespace: ${base_utils_namespace}
- name: reloader
  releaseName: reloader
  version: ${reloader_chart_version}
  repo: ${reloader_repo_url}
  valuesFile: values-reloader.yaml
  namespace: ${base_utils_namespace}
