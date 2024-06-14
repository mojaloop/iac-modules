apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
%{ if istio_create_ingress_gateways ~}
  - istio-gateway.yaml
%{ endif ~}
  - vault-rbac.yaml
  - vault-certificate.yaml
helmCharts:
- name: mojaloop-proxy-payment-manager
  releaseName: ${pm4ml_release_name}
  version: ${proxy_pm4ml_chart_version}
  repo: ${proxy_pm4ml_chart_repo}
  valuesFile: values-proxy-pm4ml.yaml
  namespace: ${pm4ml_namespace}
- name: redis
  releaseName: redis
  version: "17.6.0"
  repo: "https://charts.bitnami.com/bitnami"
  valuesFile: values-redis.yaml
  namespace: ${pm4ml_namespace}
