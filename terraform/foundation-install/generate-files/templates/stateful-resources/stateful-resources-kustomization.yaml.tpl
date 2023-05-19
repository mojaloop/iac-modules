---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: ${stateful_resources_namespace}
resources:
- external-name-services.yaml
%{ for stateful_resource in stateful_resources ~}
- vault-crs-${stateful_resource.local_resource.resource_helm_chart}-${stateful_resource.resource_name}.yaml
%{ endfor ~}
helmCharts:
%{ for stateful_resource in stateful_resources ~}
- name: ${stateful_resource.local_resource.resource_helm_chart}
  namespace: ${stateful_resource.resource_namespace}
  releaseName: ${stateful_resource.local_resource.resource_helm_chart}-${stateful_resource.resource_name}
  version: ${stateful_resource.local_resource.resource_helm_chart_version}
  repo: ${stateful_resource.local_resource.resource_helm_repo}
  valuesFile: values-${stateful_resource.local_resource.resource_helm_chart}-${stateful_resource.resource_name}.yaml
%{ endfor ~}