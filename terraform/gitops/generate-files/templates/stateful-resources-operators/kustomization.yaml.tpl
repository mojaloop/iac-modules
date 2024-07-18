apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- namespace.yaml
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
