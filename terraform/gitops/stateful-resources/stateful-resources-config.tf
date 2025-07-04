resource "local_file" "chart_values" {
  for_each = { for key, stateful_resource in local.helm_stateful_resources : key => stateful_resource }

  content = templatefile("${local.stateful_resources_template_path}/${each.value.local_helm_config.resource_helm_values_ref}", {
    resource = each.value,
    key      = each.key
    storage_class_name  = var.storage_class_name
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
# not required in case of env vpc
resource "local_file" "managed_crs" {
  for_each = local.managed_resource_password_map_non_env_vpc

  content = templatefile("${local.stateful_resources_template_path}/managed-crs.yaml.tpl", {
    password_map = each.value
  })
  filename = "${local.stateful_resources_output_path}/managed-crs-${each.key}.yaml"
}

# not required in case of env vpc
resource "local_file" "monolith_managed_crs" {
  for_each = local.monolith_managed_password_map_non_env_vpc

  content = templatefile("${local.stateful_resources_template_path}/monolith-managed-crs.yaml.tpl", {
    secret_name = each.value.secret_name
    namespace   = each.value.namespace
    secret_key  = each.value.secret_key
    vault_path  = each.value.vault_path
  })
  filename = "${local.stateful_resources_output_path}/monolith-managed-crs-${each.key}.yaml"
}

# not required in case of env vpc
resource "local_file" "mysql_managed_stateful_resources" {
  for_each = local.mysql_managed_stateful_resources_non_env_vpc

  content = templatefile("${local.stateful_resources_template_path}/managed-mysql.yaml.tpl", {
    resource_name                = each.key
    stateful_resources_namespace = var.stateful_resources_namespace
    managed_stateful_resource    = local.mysql_managed_stateful_resources_non_env_vpc[each.key]
    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
  })
  filename = "${local.stateful_resources_output_path}/managed-mysql-${each.key}.yaml"
}

# not required in case of env vpc
resource "local_file" "mongodb_managed_stateful_resources" {
  for_each = local.mongodb_managed_stateful_resources_non_env_vpc

  content = templatefile("${local.stateful_resources_template_path}/managed-mongodb.yaml.tpl", {
    resource_name                = each.key
    stateful_resources_namespace = var.stateful_resources_namespace
    managed_stateful_resource    = local.mongodb_managed_stateful_resources_non_env_vpc[each.key]
    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
  })
  filename = "${local.stateful_resources_output_path}/managed-mongodb-${each.key}.yaml"
}



resource "local_file" "external_name_services" {
  content = templatefile("${local.stateful_resources_template_path}/external-name-services.yaml.tpl",
    { config                       = local.external_name_map
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/external-name-services.yaml"
}

resource "local_file" "monolith_external_name_services" {
  count   = var.managed_svc_as_monolith ? 1 : 0
  content = templatefile("${local.stateful_resources_template_path}/monolith-external-name-services.yaml.tpl",
    { config                       = local.monolith_managed_external_name_map
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/monolith-external-name-services.yaml"
}



resource "local_file" "monolith-init-db" {
  for_each = local.monolith_init_mysql_managed_stateful_resources

  content = templatefile("${local.stateful_resources_template_path}/monolith-db-init-job.yaml.tpl", {
    resource_name                = each.key
    stateful_resources_namespace = var.stateful_resources_namespace
    managed_stateful_resource    = local.mysql_managed_stateful_resources[each.key]
    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
    monolith_stateful_resources  = var.monolith_stateful_resources
  })
  filename = "${local.stateful_resources_output_path}/monolith-db-init-job-${each.key}.yaml"
}

resource "local_file" "monolith-init-mongodb" {
  for_each = local.monolith_init_mongodb_managed_stateful_resources

  content = templatefile("${local.stateful_resources_template_path}/monolith-mongodb-init-job.yaml.tpl", {
    resource_name                = each.key
    stateful_resources_namespace = var.stateful_resources_namespace
    managed_stateful_resource    = local.mongodb_managed_stateful_resources[each.key]
    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
    monolith_stateful_resources  = var.monolith_stateful_resources
    additional_privileges        = each.value.external_resource_config.additional_privileges
    database_name                = each.value.logical_service_config.database_name
    database_user                = each.value.logical_service_config.db_username
  })
  filename = "${local.stateful_resources_output_path}/monolith-mongodb-init-job-${each.key}.yaml"
}

resource "local_file" "kustomization" {
  content = templatefile("${local.stateful_resources_template_path}/stateful-resources-kustomization.yaml.tpl",
    { all_local_stateful_resources        = local.internal_stateful_resources
      helm_stateful_resources             = local.helm_stateful_resources
      managed_stateful_resources          = local.managed_stateful_resources
      mysql_managed_stateful_resources    = local.mysql_managed_stateful_resources
      mongodb_managed_stateful_resources  = local.mongodb_managed_stateful_resources
      strimzi_operator_stateful_resources = local.strimzi_operator_stateful_resources
      redis_operator_stateful_resources   = local.redis_operator_stateful_resources
      percona_stateful_resources          = local.percona_stateful_resources
      monolith_env_vpc_aws_db_resources   = local.monolith_env_vpc_aws_db_resources
      monolith_stateful_resources         = var.monolith_stateful_resources
      managed_svc_as_monolith             = var.managed_svc_as_monolith
      deploy_env_monolithic_db            = var.deploy_env_monolithic_db
      monolith_env_vpc_resource_password_map = local.monolith_env_vpc_resource_password_map

      monolith_init_mysql_managed_stateful_resources   = local.monolith_init_mysql_managed_stateful_resources
      monolith_init_mongodb_managed_stateful_resources = local.monolith_init_mongodb_managed_stateful_resources
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
      kafka_cluster_name          = each.key
      kafka_cluster_metrics_label = var.cluster_name

      node_pool_name         = "${each.key}-nodepool"
      node_pool_size         = each.value.local_operator_config.node_pool_size
      node_pool_storage_size = each.value.local_operator_config.kafka_data.storage_size
      node_pool_storage_class_name = each.value.local_operator_config.kafka_data.storage_class_name
      node_pool_affinity     = each.value.local_operator_config.kafka_data.affinity_definition
      namespace              = each.value.local_operator_config.resource_namespace
      kafka_topics           = each.value.logical_service_config.post_install_schema_config.kafka_provisioning.enabled ? each.value.logical_service_config.post_install_schema_config.kafka_provisioning.topics : {}

      strimzi_kafka_grafana_dashboards_version = local.strimzi_kafka_grafana_dashboards_version
      strimzi_kafka_grafana_dashboards_list = ["strimzi-cruise-control", "strimzi-kafka-bridge", "strimzi-kafka-connect",
        "strimzi-kafka-exporter", "strimzi-kafka-mirror-maker-2", "strimzi-kafka-oauth",
      "strimzi-kafka", "strimzi-kraft", "strimzi-operators", "strimzi-zookeeper"]
  })
  filename = "${local.stateful_resources_output_path}/kafka-with-dual-role-nodes-${each.key}.yaml"
}

resource "local_file" "redis-crs" {

  for_each = { for key, stateful_resource in local.redis_operator_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/redis/redis-cluster.yaml.tpl",
    {
      name                   = each.key
      namespace              = each.value.local_operator_config.resource_namespace
      nodes                  = each.value.local_operator_config.nodes
      storage_size           = each.value.local_operator_config.redis_data.storage_size
      persistence_enabled    = each.value.local_operator_config.redis_data.persistence_enabled
      disable_ha             = try(
        each.value.local_operator_config.disable_ha,
        var.cluster.master_node_count + var.cluster.agent_node_count < each.value.local_operator_config.nodes,
        false
      )
      storage_class_name     = var.storage_class_name
  })
  filename = "${local.stateful_resources_output_path}/redis-cluster-${each.key}.yaml"
}

resource "local_file" "percona-crs" {

  for_each = { for key, stateful_resource in local.percona_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/percona/${each.value.resource_type}/db-cluster.yaml.tpl",
    {
      cluster_name        = each.key
      cr_version          = each.value.local_operator_config.cr_version
      replica_count       = each.value.logical_service_config.replica_count
      namespace           = each.value.local_operator_config.resource_namespace
      storage_class_name  = var.storage_class_name
      storage_size        = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data.storage_size : each.value.local_operator_config.mongodb_data.storage_size
      existing_secret     = each.value.local_operator_config.secret_config.generate_secret_name
      affinity_definition = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data.affinity_definition : each.value.local_operator_config.mongodb_data.affinity_definition

      percona_xtradb_mysql_version   = each.value.resource_type == "mysql" ? each.value.local_operator_config.percona_xtradb_mysql_version : ""
      percona_xtradb_haproxy_version = each.value.resource_type == "mysql" ? each.value.local_operator_config.percona_xtradb_haproxy_version : ""
      percona_xtradb_logcoll_version = each.value.resource_type == "mysql" ? each.value.local_operator_config.percona_xtradb_logcoll_version : ""
      percona_xtradb_backup_version  = each.value.resource_type == "mysql" ? each.value.local_operator_config.percona_xtradb_backup_version : ""
      haproxy_count                  = each.value.resource_type == "mysql" ? each.value.local_operator_config.haproxy_count : ""

      mongo_config_server_replica_count = each.value.resource_type == "mongodb" ? each.value.logical_service_config.mongo_config_server_replica_count : ""
      mongo_proxy_replica_count         = each.value.resource_type == "mongodb" ? each.value.logical_service_config.mongo_proxy_replica_count : ""
      mongod_replica_count              = each.value.logical_service_config.replica_count
      percona_server_mongodb_version    = each.value.resource_type == "mongodb" ? each.value.local_operator_config.percona_server_mongodb_version : ""
      percona_backup_mongodb_version    = each.value.resource_type == "mongodb" ? each.value.local_operator_config.percona_backup_mongodb_version : ""
      additional_privileges             = each.value.resource_type == "mongodb" ? each.value.local_operator_config.additional_privileges : []


      object_store_percona_backup_bucket = var.object_store_percona_backup_bucket
      object_store_percona_secret        = "percona-backups-secret"
      object_store_api_url               = "https://${var.object_store_api_url}"
      object_store_region                = var.object_store_region
      backupSchedule              = each.value.backup_schedule
      backupStorageName           = "${each.key}-backup-storage"

      percona_credentials_id_provider_key     = "${var.cluster_name}/${local.percona_credentials_id_provider_key}"
      percona_credentials_secret_provider_key = "${var.cluster_name}/${local.percona_credentials_secret_provider_key}"
      percona_credentials_secret              = "percona-s3-credentials-${each.key}"
      external_secret_sync_wave               = var.external_secret_sync_wave

      database_name   = each.value.logical_service_config.database_name
      database_user   = each.value.logical_service_config.db_username
      database_config = each.value.resource_type == "mysql" ? each.value.local_operator_config.mysql_data : each.value.local_operator_config.mongodb_data
  })
  filename = "${local.stateful_resources_output_path}/db-cluster-${each.key}.yaml"
}

resource "local_file" "aws-db-crs" {
  for_each = { for key, stateful_resource in local.monolith_env_vpc_aws_db_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/aws/${each.value.resource_type}/db-cluster.yaml.tpl",
    {
        cluster_name                 = "${var.cc_name}-${var.cluster_name}-${each.value.external_resource_config.dbdeploy_name_prefix}"
        dbdeploy_name_prefix         = each.value.external_resource_config.dbdeploy_name_prefix
        namespace                    = each.value.resource_namespace
        consumer_app_externalname_services = jsonencode(local.consumer_app_externalname_services[each.key])
        externalservice_name         = each.value.externalservice_name
        allow_major_version_upgrade  = each.value.external_resource_config.allow_major_version_upgrade
        apply_immediately            = each.value.external_resource_config.apply_immediately
        backup_retention_period      = each.value.external_resource_config.backup_retention_period
        db_name                      = each.value.external_resource_config.db_name
        instance_class               = each.value.external_resource_config.instance_class
        deletion_protection          = each.value.external_resource_config.deletion_protection
        engine                       = each.value.external_resource_config.engine
        engine_version               = each.value.external_resource_config.engine_version
        family                       = each.value.external_resource_config.family
        instance_count               = each.value.external_resource_config.replicas
        db_secret                    = each.value.external_resource_config.master_user_password_secret
        db_secret_key                = each.value.external_resource_config.master_user_password_secret_key
        port                         = each.value.external_resource_config.port
        preferred_backup_window      = each.value.external_resource_config.backup_window
        preferred_maintenance_window = each.value.external_resource_config.maintenance_window
        cloud_region                 = var.cloud_region
        skip_final_snapshot          = each.value.external_resource_config.skip_final_snapshot
        final_snapshot_identifier    = "${var.cc_name}-${var.cluster_name}-${each.key}-final-snapshot"
        storage_encrypted            = each.value.external_resource_config.storage_encrypted
        storage_type                 = each.value.external_resource_config.storage_type
        allocated_storage            = each.value.external_resource_config.allocated_storage
        subnet_list                  = var.database_subnets
        azs                          = var.availability_zones
        db_username                  = each.value.external_resource_config.username
        vpc_cidr                     = var.vpc_cidr
        vpc_id                       = var.vpc_id
  })
  filename = "${local.stateful_resources_output_path}/db-cluster-${each.key}.yaml"
}

resource "local_file" "aws-db-vault-crs" {
  for_each = { for key, stateful_resource in local.monolith_env_vpc_resource_password_map : key => stateful_resource }

  content = templatefile("${local.stateful_resources_template_path}/monolith-env-vpc-vault-crs.yaml.tpl", {
    key           = each.key
    namespace     = "stateful-resources"
    secret_name   = each.value.secret_name
    secret_key    = each.value.secret_key
    extra_namespaces = each.value.namespaces
  })
  filename = "${local.stateful_resources_output_path}/monolith-env-vpc-vault-crs-${each.key}.yaml"
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
  redis_operator_stateful_resources   = { for key, resource in local.operator_stateful_resources : key => resource if resource.resource_type == "redis" }
  percona_stateful_resources          = { for key, resource in local.operator_stateful_resources : key => resource if(resource.resource_type == "mysql" || resource.resource_type == "mongodb") }
  managed_stateful_resources          = { for key, managed_resource in local.stateful_resources : key => managed_resource if managed_resource.deployment_type == "external" }
  mysql_managed_stateful_resources    = { for key, managed_resource in local.managed_stateful_resources : key => managed_resource if managed_resource.resource_type == "mysql" }
  mongodb_managed_stateful_resources  = { for key, managed_resource in local.managed_stateful_resources : key => managed_resource if managed_resource.resource_type == "mongodb" }
  local_external_name_map             = { for key, stateful_resource in local.helm_stateful_resources : stateful_resource.logical_service_config.logical_service_name => try(stateful_resource.local_helm_config.override_service_name, null) != null ? "${stateful_resource.local_helm_config.override_service_name}.${stateful_resource.local_helm_config.resource_namespace}.svc.cluster.local" : "${key}.${stateful_resource.local_helm_config.resource_namespace}.svc.cluster.local" }
  local_operator_external_name_map    = { for key, stateful_resource in local.operator_stateful_resources : stateful_resource.logical_service_config.logical_service_name => try(stateful_resource.local_operator_config.override_service_name, null) != null ? "${stateful_resource.local_operator_config.override_service_name}.${stateful_resource.local_operator_config.resource_namespace}.svc.cluster.local" : "${key}.${stateful_resource.local_operator_config.resource_namespace}.svc.cluster.local" }
  managed_external_name_map           = { for key, stateful_resource in local.managed_stateful_resources : stateful_resource.logical_service_config.logical_service_name => try(var.external_stateful_resource_instance_addresses[stateful_resource.external_resource_config.instance_address_key_name], "") if var.deploy_env_monolithic_db == false }
  external_name_map                   = merge(local.local_operator_external_name_map, merge(local.local_external_name_map, local.managed_external_name_map)) # mutually exclusive maps

  managed_resource_password_map = { for key, stateful_resource in local.managed_stateful_resources : key => {
    vault_path  = "${var.kv_path}/${var.cluster_name}/${stateful_resource.external_resource_config.password_key_name}"
    namespaces  = stateful_resource.logical_service_config.secret_extra_namespaces
    secret_name = stateful_resource.logical_service_config.user_password_secret
    secret_key  = stateful_resource.logical_service_config.user_password_secret_key
    }
  }

  managed_resource_password_map_non_env_vpc = { for key, stateful_resource in local.managed_resource_password_map : key => {
    vault_path  = stateful_resource.vault_path
    namespaces  = stateful_resource.namespaces
    secret_name = stateful_resource.secret_name
    secret_key  = stateful_resource.secret_key
    } if var.deploy_env_monolithic_db == false
  }

  monolith_env_vpc_child_databases = { for key, managed_resource in local.managed_stateful_resources : key => managed_resource if var.managed_svc_as_monolith == true }

  monolith_env_vpc_resource_password_map = { for key, stateful_resource in local.monolith_env_vpc_child_databases : key => {
    namespaces  = stateful_resource.logical_service_config.secret_extra_namespaces
    secret_name = stateful_resource.logical_service_config.user_password_secret
    secret_key  = stateful_resource.logical_service_config.user_password_secret_key
    }
  }

  monolith_env_vpc_aws_db_resources =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "rds" || monolith_resource.provider == "documentdb"}
  monolith_env_vpc_dbaas_resources  =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "dbaas" }

  monolith_managed_password_map = { for key, stateful_resource in var.monolith_stateful_resources : key => {
    vault_path  = "${var.kv_path}/${var.cluster_name}/${stateful_resource.external_resource_config.password_key_name}"
    namespace   = stateful_resource.external_resource_config.master_user_password_secret_namespace
    secret_name = stateful_resource.external_resource_config.master_user_password_secret
    secret_key  = stateful_resource.external_resource_config.master_user_password_secret_key
    }
  }

  monolith_managed_password_map_non_env_vpc = { for key, stateful_resource in local.monolith_managed_password_map : key => {
    vault_path  = stateful_resource.vault_path
    namespace   = stateful_resource.namespace
    secret_name = stateful_resource.secret_name
    secret_key  = stateful_resource.secret_key
    } if var.deploy_env_monolithic_db == false
  }

  monolith_managed_external_name_map = { for key, stateful_resource in var.monolith_stateful_resources : stateful_resource.external_resource_config.logical_service_name => var.monolith_external_stateful_resource_instance_addresses[stateful_resource.external_resource_config.instance_address_key_name] if var.deploy_env_monolithic_db == false }

  monolith_init_mysql_managed_stateful_resources = { for key, resource in local.mysql_managed_stateful_resources : key => resource if var.managed_svc_as_monolith == true }
  monolith_init_mongodb_managed_stateful_resources = { for key, resource in local.mongodb_managed_stateful_resources : key => resource if var.managed_svc_as_monolith == true }

  mysql_managed_stateful_resources_non_env_vpc = { for key, resource in local.mysql_managed_stateful_resources : key => resource if var.deploy_env_monolithic_db == false }
  mongodb_managed_stateful_resources_non_env_vpc = { for key, resource in local.mongodb_managed_stateful_resources : key => resource if var.deploy_env_monolithic_db == false }


  consumer_app_externalname_services = {
    for db_server in distinct([
      for _, resource in local.managed_stateful_resources :
      resource.monolith_db_server if resource.enabled
    ]) :
    db_server => [
      for _, resource in local.managed_stateful_resources :
      resource.logical_service_config.logical_service_name
      if resource.monolith_db_server == db_server && resource.enabled
    ]
  }

  stateful_resources_vars = {
    stateful_resources_namespace = var.stateful_resources_namespace
    gitlab_project_url           = var.gitlab_project_url
    stateful_resources_sync_wave = var.stateful_resources_sync_wave
    stateful_resources_name      = local.stateful_resources_name
  }

  all_logical_extra_namespaces = flatten([for stateful_resource in local.stateful_resources : try(stateful_resource.logical_service_config.secret_extra_namespaces, "")])
  #all_local_extra_namespaces    = flatten([for stateful_resource in local.stateful_resources : try(stateful_resource.secret_config.generate_secret_extra_namespaces, "")])
  all_local_helm_namespaces = distinct([for stateful_resource in local.helm_stateful_resources : try(stateful_resource.local_helm_config.resource_namespace, "")])
  all_local_op_namespaces   = distinct([for stateful_resource in local.operator_stateful_resources : try(stateful_resource.local_operator_config.resource_namespace, "")])

  percona_credentials_secret_provider_key = "percona_bucket_secret_key_id"
  percona_credentials_id_provider_key     = "percona_bucket_access_key_id"

  strimzi_kafka_grafana_dashboards_version = "0.41.0"
}

variable "external_stateful_resource_instance_addresses" {
}

variable "monolith_external_stateful_resource_instance_addresses" {
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

variable "object_store_api_url" {
  type        = string
  description = "object_store_api_url"
}

variable "object_store_region" {
  type        = string
  description = "object_store_region"
}

variable "object_store_percona_backup_bucket" {
  type        = string
  description = "object_store_percona_backup_bucket"
}

variable "monolith_stateful_resources" {
  type = any
}

variable "managed_svc_as_monolith" {
}

variable "cluster" {
  type = any
}

variable "storage_class_name" {
}

variable "cc_name" {
  type        = string
  description = "The name of the control center."
}

variable "cloud_region" {
  type        = string
  description = "The AWS region where resources will be deployed."
}

variable "database_subnets" {
  type        = string
  description = "A list of subnet IDs to deploy the database instances into."
}

variable "availability_zones" {
  type        = string
  description = "A list of availability zones for the database instances."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be deployed."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC."
}

variable "deploy_env_monolithic_db" {
  type        = bool
  default     = false
}