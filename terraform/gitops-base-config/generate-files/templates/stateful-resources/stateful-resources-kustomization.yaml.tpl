---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- external-name-services.yaml
- namespace.yaml
%{ for stateful_resource in local_stateful_resources ~}
- vault-crs-${stateful_resource.resource_name}.yaml
%{ endfor ~}
%{ for stateful_resource in managed_stateful_resources ~}
- managed-crs-${stateful_resource.resource_name}.yaml
%{ endfor ~}
helmCharts:
%{ for stateful_resource in local_stateful_resources ~}
- name: ${stateful_resource.local_resource.resource_helm_chart}
  namespace: ${stateful_resource.resource_namespace}
  releaseName: ${stateful_resource.local_resource.resource_helm_chart}-${stateful_resource.resource_name}
  version: ${stateful_resource.local_resource.resource_helm_chart_version}
  repo: ${stateful_resource.local_resource.resource_helm_repo}
  valuesFile: values-${stateful_resource.local_resource.resource_helm_chart}-${stateful_resource.resource_name}.yaml
%{ endfor ~}