---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
# %{ if deploy_env_monolithic_db == false }
- external-name-services.yaml
# %{ endif }

# %{ for key, stateful_resource in monolith_env_vpc_resource_password_map }
- monolith-env-vpc-vault-crs-${key}.yaml
# %{ endfor }

# %{ if managed_svc_as_monolith }
- monolith-external-name-services.yaml
# %{ endif }
- namespace.yaml
# %{ for key, stateful_resource in all_local_stateful_resources }
- vault-crs-${key}.yaml
# %{ endfor }

# %{ for key,stateful_resource in monolith_init_mysql_managed_stateful_resources }
- monolith-db-init-job-${key}.yaml
# %{ endfor }

# %{ for key,stateful_resource in monolith_init_mongodb_managed_stateful_resources }
- monolith-mongodb-init-job-${key}.yaml
# %{ endfor }

# %{ for key,stateful_resource in strimzi_operator_stateful_resources }
- kafka-with-dual-role-nodes-${key}.yaml
# %{ endfor }

# %{ for key,stateful_resource in redis_operator_stateful_resources }
- redis-cluster-${key}.yaml
# %{ endfor }

# %{ for key,stateful_resource in percona_stateful_resources }
- db-cluster-${key}.yaml
# %{ endfor }
helmCharts:
# %{ for key, stateful_resource in helm_stateful_resources }
- name: ${stateful_resource.local_helm_config.resource_helm_chart}
  namespace: ${stateful_resource.local_helm_config.resource_namespace}
  releaseName: ${stateful_resource.local_helm_config.resource_helm_chart}-${key}
  version: ${stateful_resource.local_helm_config.resource_helm_chart_version}
  repo: ${stateful_resource.local_helm_config.resource_helm_repo}
  valuesFile: values-${stateful_resource.local_helm_config.resource_helm_chart}-${key}.yaml
# %{ endfor }
