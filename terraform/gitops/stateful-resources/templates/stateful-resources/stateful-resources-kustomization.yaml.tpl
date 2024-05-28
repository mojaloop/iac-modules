---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- external-name-services.yaml
- namespace.yaml
%{ for key, stateful_resource in all_local_stateful_resources ~}
- vault-crs-${key}.yaml
%{ endfor ~}
%{ for key,stateful_resource in managed_stateful_resources ~}
- managed-crs-${key}.yaml
%{ endfor ~}
%{ for key,stateful_resource in strimzi_operator_stateful_resources ~}
- kafka-with-dual-role-nodes-${key}.yaml
%{ endfor ~}
%{ for key,stateful_resource in percona_mysql_stateful_resources ~}
- db-cluster-${key}.yaml
%{ endfor ~}
helmCharts:
%{ for key, stateful_resource in helm_stateful_resources ~}
- name: ${stateful_resource.local_helm_config.resource_helm_chart}
  namespace: ${stateful_resource.local_helm_config.resource_namespace}
  releaseName: ${stateful_resource.local_helm_config.resource_helm_chart}-${key}
  version: ${stateful_resource.local_helm_config.resource_helm_chart_version}
  repo: ${stateful_resource.local_helm_config.resource_helm_repo}
  valuesFile: values-${stateful_resource.local_helm_config.resource_helm_chart}-${key}.yaml
%{ endfor ~}