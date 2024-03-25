apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - istio-config.yaml
  - switch-jws-deployment.yaml
  - vault-secret.yaml
helmCharts:
- name: vnext
  releaseName: ${vnext_release_name}
  version: ${vnext_chart_version}
  repo: ${vnext_chart_repo}
  valuesFile: values-vnext.yaml
  namespace: ${vnext_namespace}
