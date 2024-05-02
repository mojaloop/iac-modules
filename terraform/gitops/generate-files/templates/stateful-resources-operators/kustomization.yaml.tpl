apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- namespace.yaml
helmCharts:
%{ for stateful_resource_operator in stateful_resource_operators ~}
- name: ${stateful_resource_operator.helm_chart}
  namespace: ${stateful_resource_operator.namespace}
  releaseName: ${stateful_resource_operator.release_name}
  version: ${stateful_resource_operator.helm_chart_version}
  repo: ${stateful_resource_operator.helm_chart_repo}
  valuesFile: ${stateful_resource_operator.helm_chart_values_file}
%{ endfor ~}