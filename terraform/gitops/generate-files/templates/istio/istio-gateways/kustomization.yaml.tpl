apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yaml
  - lets-wildcard-cert-external.yaml
  - lets-wildcard-cert-internal.yaml
  - proxy-protocol.yaml
  - gateways.yaml
  - argocd-vs.yaml
helmCharts:
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