resource "local_file" "chart_values" {
  for_each = { for key, stateful_resource in local.helm_stateful_resources : key => stateful_resource }

  content = templatefile("${local.stateful_resources_template_path}/${each.value.local_helm_config.resource_helm_values_ref}", {
    resource = each.value,
    key      = each.key
  })
  filename = "${local.stateful_resources_output_path}/values-${each.value.local_helm_config.resource_helm_chart}-${each.key}.yaml"
}

resource "local_file" "vault_crs" {
  for_each = { for key, stateful_resource in local.internal_stateful_resources : key => stateful_resource }

  content = templatefile("${local.stateful_resources_template_path}/vault-crs.yaml.tpl", {
    resource      = each.value,
    key           = each.key
    namespace     = each.value.deployment_type == "helm-chart" ? each.value.local_helm_config.resource_namespace : each.value.local_operator_config.resource_namespace
    secret_config = each.value.deployment_type == "helm-chart" ? each.value.local_helm_config.secret_config : each.value.local_operator_config.secret_config
  })
  filename = "${local.stateful_resources_output_path}/vault-crs-${each.key}.yaml"
}

resource "local_file" "managed_crs" {
  for_each = local.managed_resource_password_map

  content = templatefile("${local.stateful_resources_template_path}/managed-crs.yaml.tpl", {
    password_map = each.value
  })
  filename = "${local.stateful_resources_output_path}/managed-crs-${each.key}.yaml"
}

resource "local_file" "external_name_services" {
  content = templatefile("${local.stateful_resources_template_path}/external-name-services.yaml.tpl",
    { config                       = local.external_name_map
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/external-name-services.yaml"
}

resource "local_file" "kustomization" {
  content = templatefile("${local.stateful_resources_template_path}/stateful-resources-kustomization.yaml.tpl",
    { all_local_stateful_resources        = local.internal_stateful_resources
      helm_stateful_resources             = local.helm_stateful_resources
      managed_stateful_resources          = local.managed_stateful_resources
      strimzi_operator_stateful_resources = local.strimzi_operator_stateful_resources
      percona_stateful_resources          = local.percona_stateful_resources
  })
  filename = "${local.stateful_resources_output_path}/kustomization.yaml"
}

resource "local_file" "namespace" {
  content = templatefile("${local.stateful_resources_template_path}/namespace.yaml.tpl",
    {
      all_ns = distinct(concat(var.create_stateful_resources_ns ? [var.stateful_resources_namespace] : [], local.all_logical_extra_namespaces, local.all_local_helm_namespaces, local.all_local_op_namespaces))
  })
  filename = "${local.stateful_resources_output_path}/namespace.yaml"
}

resource "local_file" "strimzi-crs" {

  for_each = { for key, stateful_resource in local.strimzi_operator_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/strimzi/kafka/kafka-with-dual-role-nodes.yaml.tpl",
    {
      kafka_cluster_name     = each.key
      node_pool_name         = "${each.key}-nodepool"
      node_pool_size         = each.value.local_operator_config.node_pool_size
      node_pool_storage_size = each.value.local_operator_config.kafka_data.storage_size
      node_pool_affinity     = each.value.local_operator_config.kafka_data.affinity_definition
      namespace          = each.value.local_operator_config.resource_namespace
      kafka_topics       = each.value.logical_service_config.post_install_schema_config.kafka_provisioning.enabled ? each.value.logical_service_config.post_install_schema_config.kafka_provisioning.topics : {}

      strimzi_kafka_grafana_dashboards_version = local.strimzi_kafka_grafana_dashboards_version
      strimzi_kafka_grafana_dashboards_list = ["strimzi-cruise-control", "strimzi-kafka-bridge", "strimzi-kafka-connect",
        "strimzi-kafka-exporter", "strimzi-kafka-mirror-maker-2", "strimzi-kafka-oauth",
      "strimzi-kafka", "strimzi-kraft", "strimzi-operators", "strimzi-zookeeper"]
  })
  filename = "${local.stateful_resources_output_path}/kafka-with-dual-role-nodes-${each.key}.yaml"
}

resource "local_file" "percona-crs" {

  for_each = { for key, stateful_resource in local.percona_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/percona/${each.value.resource_type}/db-cluster.yaml.tpl",
    {
      cluster_name       = each.key
      cr_version         = each.value.local_operator_config.cr_version
      replica_count      = each.value.logical_service_config.replica_count
      namespace          = each.value.local_operator_config.resource_namespace
      storage_class_name = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data.storage_class_name : each.value.local_operator_config.mongodb_data.storage_class_name
      storage_size       = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data.storage_size : each.value.local_operator_config.mongodb_data.storage_size
      existing_secret    = each.value.local_operator_config.secret_config.generate_secret_name
      affinity           = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data.affinity_definition : each.value.local_operator_config.mongodb_data.affinity_definition


      mongo_config_server_replica_count = each.value.resource_type == "mongodb" ? each.value.logical_service_config.mongo_config_server_replica_count : ""
      mongo_proxy_replica_count         = each.value.resource_type == "mongodb" ? each.value.logical_service_config.mongo_proxy_replica_count : ""
      mongod_replica_count              = each.value.logical_service_config.replica_count
      percona_server_mongodb_version    = each.value.resource_type == "mongodb" ? each.value.local_operator_config.percona_server_mongodb_version : ""


      minio_percona_backup_bucket = var.minio_percona_backup_bucket
      minio_percona_secret        = "percona-backups-secret"
      minio_api_url               = "http://${var.minio_api_url}"
      backupSchedule              = each.value.backup_schedule
      backupStorageName           = "${each.key}-backup-storage"

      percona_credentials_id_provider_key     = "${var.cluster_name}/${local.percona_credentials_id_provider_key}"
      percona_credentials_secret_provider_key = "${var.cluster_name}/${local.percona_credentials_secret_provider_key}"
      percona_credentials_secret              = "percona-s3-credentials-${each.key}"
      external_secret_sync_wave               = var.external_secret_sync_wave

      database_name    = each.value.logical_service_config.database_name
      database_user    = each.value.logical_service_config.db_username
      database_config  = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data : each.value.local_operator_config.mongodb_data
  })
  filename = "${local.stateful_resources_output_path}/db-cluster-${each.key}.yaml"
}

resource "local_file" "stateful-resources-app-file" {
  content  = templatefile("${local.stateful_resources_template_path}/app/${local.stateful_resources_app_file}.tpl", local.stateful_resources_vars)
  filename = "${local.app_stateful_resources_output_path}/${local.stateful_resources_name}-${local.stateful_resources_app_file}"
}

locals {
  stateful_resources_name             = var.stateful_resources_name
  stateful_resources_template_path    = "${path.module}/templates/stateful-resources"
  stateful_resources_output_path      = "${var.output_dir}/${local.stateful_resources_name}-stateful-resources"
  stateful_resources_app_file         = "stateful-resources-app.yaml"
  app_stateful_resources_output_path  = "${var.output_dir}/app-yamls"
  stateful_resources                  = var.stateful_resources
  helm_stateful_resources             = { for key, resource in local.stateful_resources : key => resource if resource.deployment_type == "helm-chart" }
  operator_stateful_resources         = { for key, resource in local.stateful_resources : key => resource if resource.deployment_type == "operator" }
  internal_stateful_resources         = { for key, resource in local.stateful_resources : key => resource if(resource.deployment_type == "operator" || resource.deployment_type == "helm-chart") }
  strimzi_operator_stateful_resources = { for key, resource in local.operator_stateful_resources : key => resource if resource.resource_type == "kafka" }
  percona_stateful_resources          = { for key, resource in local.operator_stateful_resources : key => resource if ( resource.resource_type == "mysql" || resource.resource_type == "mongodb" )}
  managed_stateful_resources          = { for key, managed_resource in local.stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" }
  local_external_name_map             = { for key, stateful_resource in local.helm_stateful_resources : stateful_resource.logical_service_config.logical_service_name => try(stateful_resource.local_helm_config.override_service_name, null) != null ? "${stateful_resource.local_helm_config.override_service_name}.${stateful_resource.local_helm_config.resource_namespace}.svc.cluster.local" : "${key}.${stateful_resource.local_helm_config.resource_namespace}.svc.cluster.local" }
  local_operator_external_name_map    = { for key, stateful_resource in local.operator_stateful_resources : stateful_resource.logical_service_config.logical_service_name => try(stateful_resource.local_operator_config.override_service_name, null) != null ? "${stateful_resource.local_operator_config.override_service_name}.${stateful_resource.local_operator_config.resource_namespace}.svc.cluster.local" : "${key}.${stateful_resource.local_operator_config.resource_namespace}.svc.cluster.local" }
  managed_external_name_map           = { for key, stateful_resource in local.managed_stateful_resources : stateful_resource.logical_service_config.logical_service_name => var.managed_db_host }
  external_name_map                   = merge(local.local_operator_external_name_map, merge(local.local_external_name_map, local.managed_external_name_map)) # mutually exclusive maps
  managed_resource_password_map = { for key, stateful_resource in local.managed_stateful_resources : key => {
    vault_path  = "${var.kv_path}/${var.cluster_name}/${stateful_resource.external_resource_config.password_key_name}"
    namespaces  = stateful_resource.logical_service_config.secret_extra_namespaces
    secret_name = stateful_resource.logical_service_config.user_password_secret
    secret_key  = stateful_resource.logical_service_config.user_password_secret_key
    }
  }

  stateful_resources_vars = {
    stateful_resources_namespace = var.stateful_resources_namespace
    gitlab_project_url           = var.gitlab_project_url
    stateful_resources_sync_wave = var.stateful_resources_sync_wave
    stateful_resources_name      = local.stateful_resources_name
  }

  all_logical_extra_namespaces  = flatten([for stateful_resource in local.stateful_resources : try(stateful_resource.logical_service_config.secret_extra_namespaces, "")])
  #all_local_extra_namespaces    = flatten([for stateful_resource in local.stateful_resources : try(stateful_resource.secret_config.generate_secret_extra_namespaces, "")])
  all_local_helm_namespaces     = distinct([for stateful_resource in local.helm_stateful_resources : try(stateful_resource.local_helm_config.resource_namespace, "")])
  all_local_op_namespaces       = distinct([for stateful_resource in local.operator_stateful_resources : try(stateful_resource.local_operator_config.resource_namespace, "")])

  percona_credentials_secret_provider_key = "minio_percona_password"
  percona_credentials_id_provider_key     = "minio_percona_username"

  strimzi_kafka_grafana_dashboards_version = "0.41.0"
}

variable "external_stateful_resource_instance_addresses" {
}

variable "create_stateful_resources_ns" {
  type        = bool
  description = "whether to create st res ns"
  default     = false
}

variable "gitlab_project_url" {
  type        = string
  description = "gitlab_project_url"
}

variable "cluster_name" {
  description = "Cluster name, lower case and without spaces. This will be used to set tags and name resources"
  type        = string
}

variable "gitlab_server_url" {
  type        = string
  description = "gitlab_server_url"
}

variable "current_gitlab_project_id" {
  type        = string
  description = "current_gitlab_project_id"
}

variable "kv_path" {
  description = "path for tenant kv engine"
  default     = "secret"
}


variable "stateful_resources_namespace" {
  type        = string
  description = "stateful_resources_namespace"
  default     = "stateful-resources"
}

variable "stateful_resources_name" {
  type        = string
  description = "stateful_resources_name"
}

variable "output_dir" {
  type        = string
  description = "output_dir"
}

variable "stateful_resources_sync_wave" {
  type        = string
  description = "stateful_resources_sync_wave, wait for vault config operator"
  default     = "-5"
}

variable "external_secret_sync_wave" {
  type        = string
  description = "external_secret_sync_wave"
  default     = "-11"
}

variable "managed_db_host" {
  type        = string
  description = "url to managed db based on haproxy"
}

variable "stateful_resources" {
  type = any
}

variable "minio_api_url" {
  type        = string
  description = "minio_api_url"
}

variable "minio_percona_backup_bucket" {
  type        = string
  description = "minio_percona_backup_bucket"
}
