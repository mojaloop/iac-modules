apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/kubernetes-sigs/gateway-api/config/crd?ref=${gateway_api_version}
  - namespace.yaml
helmCharts:
- name: base
  releaseName: istio-base
  version: ${istio_chart_version}
  repo: ${istio_chart_repo}
  valuesFile: values-istio-base.yaml
  namespace: ${istio_namespace}
- name: istiod
  releaseName: istio-istiod
  version: ${istio_chart_version}
  repo: ${istio_chart_repo}
  valuesFile: values-istio-istiod.yaml
  namespace: ${istio_namespace}