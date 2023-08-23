apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/kubernetes-sigs/gateway-api/config/crd?ref=${gateway_api_version}
  - namespace.yaml
%{ if istio_create_ingress_gateways ~}
  - lets-wildcard-cert.yaml
%{ endif ~}
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
%{ if istio_create_ingress_gateways ~}
- name: gateway
  releaseName: ext-gateway
  version: ${istio_chart_version}
  repo: ${istio_chart_repo}
  valuesFile: values-istio-external-ingress-gateway.yaml
  namespace: ${istio_external_gateway_namespace}
- name: gateway
  releaseName: int-gateway
  version: ${istio_chart_version}
  repo: ${istio_chart_repo}
  valuesFile: values-istio-internal-ingress-gateway.yaml
  namespace: ${istio_internal_gateway_namespace}
%{ endif ~}