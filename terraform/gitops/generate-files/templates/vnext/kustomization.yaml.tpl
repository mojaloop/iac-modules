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
- name: elasticsearch
  releaseName: elasticsearch
  version: 20.0.0
  repo: https://charts.bitnami.com/bitnami
  namespace: monitoring
- name: ml-testing-toolkit
  releaseName: moja
  version: 17.4.0
  repo: http://mojaloop.io/helm/repo
  namespace: ${vnext_namespace}