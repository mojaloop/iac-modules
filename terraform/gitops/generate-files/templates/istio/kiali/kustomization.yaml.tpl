apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - kiali-virtual-service.yaml
helmCharts:
- name: kiali-server
  releaseName: kiali-server
  version: ${kiali_chart_version}
  repo: ${kiali_chart_repo}
  valuesFile: values-kiali.yaml
  namespace: ${istio_namespace}
