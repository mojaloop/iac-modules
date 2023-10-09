apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-certificate.yaml
  - vault-rbac.yaml
  - vault-agent.yaml
  - keycloak-realm-cr.yaml
%{ if istio_create_ingress_gateways ~}
  - istio-gateway.yaml
%{ endif ~}
configMapGenerator:
  - name: vault-agent
    files:
      - config.hcl=configmaps/vault-config-configmap.hcl
      - config-init.hcl=configmaps/vault-config-init-configmap.hcl
generatorOptions:
  disableNameSuffixHash: true
helmCharts:
- name: connection-manager
  releaseName: mcm
  version: ${mcm_chart_version}
  repo: ${mcm_chart_repo}
  valuesFile: values-mcm.yaml
  namespace: ${mcm_namespace}