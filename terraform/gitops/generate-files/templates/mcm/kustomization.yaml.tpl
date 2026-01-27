apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
  - vault-certificate.yaml
  - vault-agent.yaml
  - rbac.yaml
  - service-ingress-waypoint.yaml
  - authorization-grafana.yaml
# %{ if istio_create_ingress_gateways }
  - istio-gateway.yaml
# %{ endif }
  - service-monitors.yaml
  - mcm-rbac-test-job.yaml
configMapGenerator:
  - name: vault-agent
    files:
      - config.hcl=configmaps/vault-config-configmap.hcl
      - config-init.hcl=configmaps/vault-config-init-configmap.hcl
generatorOptions:
  disableNameSuffixHash: true
  labels:
    reloader: enabled
helmCharts:
- name: connection-manager
  releaseName: mcm
  version: ${mcm_chart_version}
  repo: ${mcm_chart_repo}
  valuesFile: values-mcm.yaml
  namespace: ${mcm_namespace}
  additionalValuesFiles:
  - values-mcm-override.yaml
patches:
  - target:
      kind: Service
    patch: |-
      - op: add
        path: /metadata/labels/istio.io~1ingress-use-waypoint
        value: 'true'
