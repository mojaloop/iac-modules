apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
resources:
- namespace.yaml
%{ if contains(stateful_resources_operators, "redis") ~}
patches:
  - patch: |-
      apiVersion: apiextensions.k8s.io/v1
      kind: CustomResourceDefinition
      metadata:
        annotations:
          cert-manager.io/inject-ca-from: redis/serving-cert
        name: redisclusters.redis.redis.opstreelabs.in
%{ endif ~}
helmCharts:
%{ for stateful_resources_operator in stateful_resources_operators ~}
- name: ${stateful_resources_operator.helm_chart}
  namespace: ${stateful_resources_operator.namespace}
  releaseName: ${stateful_resources_operator.release_name}
  version: ${stateful_resources_operator.helm_chart_version}
  repo: ${stateful_resources_operator.helm_chart_repo}
  valuesFile: ${stateful_resources_operator.helm_chart_values_file}
  includeCRDs: true
%{ endfor ~}
