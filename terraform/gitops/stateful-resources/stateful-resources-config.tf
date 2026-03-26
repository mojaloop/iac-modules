resource "local_file" "chart_values" {
  for_each = { for key, stateful_resource in local.helm_stateful_resources_resolved : key => stateful_resource }

  content = templatefile("${local.stateful_resources_template_path}/${each.value.local_helm_config.resource_helm_values_ref}", {
    resource           = each.value,
    key                = each.key
    storage_class_name = var.storage_class_name
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


resource "local_file" "external_name_services" {
  content = templatefile("${local.stateful_resources_template_path}/external-name-services.yaml.tpl",
    { config                       = local.external_name_map
      stateful_resources_namespace = var.stateful_resources_namespace
  })
  filename = "${local.stateful_resources_output_path}/external-name-services.yaml"
}

resource "local_file" "monolith-init-db" {
  for_each = local.monolith_init_mysql_managed_stateful_resources

  content = templatefile("${local.stateful_resources_template_path}/monolith-db-init-job.yaml.tpl", {
    resource_name                = each.key
    stateful_resources_namespace = var.stateful_resources_namespace
    managed_stateful_resource    = local.mysql_managed_stateful_resources[each.key]
#    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
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
#    resource_password_vault_path = local.managed_resource_password_map[each.key].vault_path
    monolith_stateful_resources  = var.monolith_stateful_resources
    additional_privileges        = each.value.logical_service_config.additional_privileges
    database_name                = each.value.logical_service_config.database_name
    database_user                = each.value.logical_service_config.db_username
  })
  filename = "${local.stateful_resources_output_path}/monolith-mongodb-init-job-${each.key}.yaml"
}

resource "local_file" "kustomization" {
  content = templatefile("${local.stateful_resources_template_path}/stateful-resources-kustomization.yaml.tpl",
    { all_local_stateful_resources        = local.internal_stateful_resources
      helm_stateful_resources             = local.helm_stateful_resources_resolved
      managed_stateful_resources          = local.managed_stateful_resources
      mysql_managed_stateful_resources    = local.mysql_managed_stateful_resources
      mongodb_managed_stateful_resources  = local.mongodb_managed_stateful_resources
      strimzi_operator_stateful_resources = local.strimzi_operator_stateful_resources
      redis_operator_stateful_resources   = local.redis_operator_stateful_resources
      percona_stateful_resources          = local.percona_stateful_resources
      monolith_env_vpc_aws_db_resources   = local.monolith_env_vpc_aws_db_resources
      monolith_resources_to_monitor       = local.monolith_resources_to_monitor
      monolith_env_mysql_dbaas_resources  = local.monolith_env_mysql_dbaas_resources
      monolith_env_mongo_dbaas_resources  = local.monolith_env_mongo_dbaas_resources
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
      namespace_meta = var.namespace_meta
  })
  filename = "${local.stateful_resources_output_path}/namespace.yaml"
}

resource "local_file" "strimzi-crs" {

  for_each = { for key, stateful_resource in local.strimzi_operator_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/strimzi/kafka/kafka-with-dual-role-nodes.yaml.tpl",
    {
      kafka_cluster_name          = each.key
      kafka_cluster_metrics_label = var.cluster_name

      node_pool_name               = "${each.key}-nodepool"
      node_pool_size               = each.value.local_operator_config.node_pool_size
      scrape_interval              = try(each.value.local_operator_config.scrape_interval, null)
      node_pool_storage_size       = each.value.local_operator_config.kafka_data.storage_size
      node_pool_storage_class_name = each.value.local_operator_config.kafka_data.storage_class_name
      node_pool_affinity           = each.value.local_operator_config.kafka_data.affinity_definition
      tolerations                  = each.value.local_operator_config.kafka_data.tolerations
      namespace                    = each.value.local_operator_config.resource_namespace

      kafka_version          = try(each.value.local_operator_config.kafka_data.kafka_version, "3.7.0")
      kafka_metadata_version = try(each.value.local_operator_config.kafka_data.kafka_metadata_version, "3.7-IV4")
      # Kafka broker config defaults. Override/extend via custom-config:
      #   mojaloop-kafka.local_operator_config.kafka_data.broker_config:
      #     <key>: <value>
      kafka_broker_config = merge(
        {
          "offsets.topic.replication.factor"         = 3
          "transaction.state.log.replication.factor" = 3
          "transaction.state.log.min.isr"            = 2
          "default.replication.factor"               = 3
          "min.insync.replicas"                      = 2
          "log.message.timestamp.type"               = "LogAppendTime"
        },
        try(each.value.local_operator_config.kafka_data.broker_config, {})
      )
      kafka_topics = each.value.logical_service_config.post_install_schema_config.kafka_provisioning.enabled ? each.value.logical_service_config.post_install_schema_config.kafka_provisioning.topics : {}

      strimzi_kafka_grafana_dashboards_version = local.strimzi_kafka_grafana_dashboards_version
      strimzi_kafka_grafana_dashboards_list = [
        "strimzi-cruise-control", "strimzi-kafka-bridge", "strimzi-kafka-connect",
        "strimzi-kafka-exporter", "strimzi-kafka-mirror-maker-2", "strimzi-kafka-oauth",
        "strimzi-kafka", "strimzi-kraft", "strimzi-operators"
      ]
  })
  filename = "${local.stateful_resources_output_path}/kafka-with-dual-role-nodes-${each.key}.yaml"
}

resource "local_file" "redis-crs" {

  for_each = { for key, stateful_resource in local.redis_operator_stateful_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/redis/redis-cluster.yaml.tpl",
    {
      name                = each.key
      namespace           = each.value.local_operator_config.resource_namespace
      nodes               = each.value.local_operator_config.nodes
      storage_size        = each.value.local_operator_config.redis_data.storage_size
      persistence_enabled = each.value.local_operator_config.redis_data.persistence_enabled
      disable_ha = try(
        each.value.local_operator_config.disable_ha,
        var.cluster.master_node_count + var.cluster.agent_node_count < each.value.local_operator_config.nodes,
        false
      )
      storage_class_name = var.storage_class_name
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
      additional_privileges             = each.value.resource_type == "mongodb" ? each.value.logical_service_config.additional_privileges : []


      object_store_percona_backup_bucket = var.object_store_percona_backup_bucket
      object_store_percona_secret        = "percona-backups-secret"
      object_store_api_url               = "https://${var.object_store_api_url}"
      object_store_region                = var.object_store_region
      backupSchedule                     = each.value.backup_schedule
      backupStorageName                  = "${each.key}-backup-storage"

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

resource "local_file" "dbaas-crs-mysql" {
  for_each = { for key, stateful_resource in local.monolith_env_mysql_dbaas_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/dbaas/${each.value.resource_type}/db-cluster.yaml.tpl",
    {
        cluster_name                 = var.cluster_name
        db_cluster_name              = each.value.dbaas_resource_config.cluster_name
        dbdeploy_name_prefix         = each.value.external_resource_config.dbdeploy_name_prefix
        namespace                    = each.value.resource_namespace
        appNamespace                 = each.value.resource_namespace

        consumer_app_externalname_services         = jsonencode(local.consumer_app_externalname_services[each.key])
        consumer_app_replica_externalname_services = jsonencode(local.consumer_app_replica_externalname_services[each.key])

        consumer_app_secret          = local.ca_bundle_secrets_by_monolith[each.key]
        cr_version                   = each.value.dbaas_resource_config.cr_version
        db_username                  = each.value.external_resource_config.username
        db_secret                    = each.value.external_resource_config.master_user_password_secret
        db_source_secret             = each.value.external_resource_config.db_source_secret
        db_secret_key                = each.value.external_resource_config.master_user_password_secret_key
        externalservice_name         = each.value.externalservice_name
        replica_externalservice_name = each.value.dbaas_resource_config.replica_external_service_name
        db_name                      = each.value.external_resource_config.db_name
        mysql_storage_size           = each.value.dbaas_resource_config.mysql_storage_size
        pxc_image                    = each.value.dbaas_resource_config.pxc_image
        mysql_replicas               = each.value.dbaas_resource_config.mysql_replicas
        mysql_requests_memory        = each.value.dbaas_resource_config.mysql_requests_memory
        mysql_requests_cpu           = each.value.dbaas_resource_config.mysql_requests_cpu
        mysql_limits_memory          = each.value.dbaas_resource_config.mysql_limits_memory
        mysql_limits_cpu             = each.value.dbaas_resource_config.mysql_limits_cpu
        haproxy_image                = each.value.dbaas_resource_config.haproxy_image
        haproxy_expose               = each.value.dbaas_resource_config.haproxy_expose
        haproxy_replicas             = each.value.dbaas_resource_config.haproxy_replicas
        haproxy_requests_memory      = each.value.dbaas_resource_config.haproxy_requests_memory
        haproxy_requests_cpu         = each.value.dbaas_resource_config.haproxy_requests_cpu
        haproxy_limits_memory        = each.value.dbaas_resource_config.haproxy_limits_memory
        haproxy_limits_cpu           = each.value.dbaas_resource_config.haproxy_limits_cpu
        logcollector_image           = each.value.dbaas_resource_config.logcollector_image
        logcollector_requests_memory  = each.value.dbaas_resource_config.logcollector_requests_memory
        logcollector_requests_cpu     = each.value.dbaas_resource_config.logcollector_requests_cpu
        logcollector_limits_memory    = each.value.dbaas_resource_config.logcollector_limits_memory
        logcollector_limits_cpu       = each.value.dbaas_resource_config.logcollector_limits_cpu
        enable_backup                = each.value.dbaas_resource_config.enable_backup
        backup_image                 = each.value.dbaas_resource_config.backup_image
        backup_verify_tls            = each.value.dbaas_resource_config.backup_verify_tls
        backup_schedule_name         = each.value.dbaas_resource_config.backup_schedule_name
        backup_cron_schedule         = each.value.dbaas_resource_config.backup_cron_schedule
        backup_retention             = each.value.dbaas_resource_config.backup_retention
        dns_name                     = "${each.value.externalservice_name}.${var.dbaas_subdomain}"
        management_policy            = each.value.dbaas_resource_config.management_policy
        cloud_region                 = var.cloud_region
        dns_zone_id                  = var.private_dns_zone_id
        cc_name                      = var.cc_name
        backup_pvc                   = jsonencode(each.value.dbaas_resource_config.backup_pvc)
        pxc_annotations              = jsonencode(each.value.dbaas_resource_config.pxc_annotations)
        pxc_volume_spec              = jsonencode(each.value.dbaas_resource_config.pxc_volume_spec)
        mysql_configuration          = each.value.dbaas_resource_config.mysql_config
        istio_nb_egress_waypoint_name   = var.istio_nb_egress_waypoint_name
        istio_nb_egress_waypoint_namespace = var.istio_nb_egress_waypoint_namespace
  })
  filename = "${local.stateful_resources_output_path}/db-cluster-${each.key}.yaml"
}

resource "local_file" "dbaas-crs-mongodb" {
  for_each = { for key, stateful_resource in local.monolith_env_mongo_dbaas_resources : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/dbaas/${each.value.resource_type}/db-cluster.yaml.tpl",
    {
        cluster_name                 = var.cluster_name
        db_cluster_name              = each.value.dbaas_resource_config.cluster_name
        externalservice_name         = each.value.externalservice_name
        appNamespace                 = each.value.resource_namespace
        consumer_app_externalname_services = jsonencode(local.consumer_app_externalname_services[each.key])
        consumer_app_secret          = local.ca_bundle_secrets_by_monolith[each.key]
        namespace                    = each.value.resource_namespace
        cr_version                   = each.value.dbaas_resource_config.cr_version
        image                        = each.value.dbaas_resource_config.image
        db_secret                    = each.value.external_resource_config.master_user_password_secret
        db_source_secret             = each.value.external_resource_config.db_source_secret
        enable_backup               = each.value.dbaas_resource_config.enable_backup
        backup_verify_tls            = each.value.dbaas_resource_config.backup_verify_tls
        backup_image                 = each.value.dbaas_resource_config.backup_image
        backup_bucket_region         = var.cloud_region
        schedule_enabled             = each.value.dbaas_resource_config.schedule_enabled
        backup_schedule_name         = each.value.dbaas_resource_config.backup_schedule_name
        backup_cron_schedule         = each.value.dbaas_resource_config.backup_cron_schedule
        backup_retention             = each.value.dbaas_resource_config.backup_retention
        replset_name                 = each.value.dbaas_resource_config.replset_name
        replset_size                 = each.value.dbaas_resource_config.replset_size
        replset_limits_cpu           = each.value.dbaas_resource_config.replset_limits_cpu
        replset_limits_memory        = each.value.dbaas_resource_config.replset_limits_memory
        replset_requests_cpu         = each.value.dbaas_resource_config.replset_requests_cpu
        replset_requests_memory      = each.value.dbaas_resource_config.replset_requests_memory
        configsvr_expose_enabled     = each.value.dbaas_resource_config.configsvr_expose_enabled
        configsvr_expose_type        = each.value.dbaas_resource_config.configsvr_expose_type
        replsets_expose_enabled      = each.value.dbaas_resource_config.replsets_expose_enabled
        replsets_expose_type         = each.value.dbaas_resource_config.replsets_expose_type
        replset_storage              = each.value.dbaas_resource_config.replset_storage
        sharding_enabled             = each.value.dbaas_resource_config.sharding_enabled
        configsvr_size               = each.value.dbaas_resource_config.configsvr_size
        configsvr_limits_cpu         = each.value.dbaas_resource_config.configsvr_limits_cpu
        configsvr_limits_memory      = each.value.dbaas_resource_config.configsvr_limits_memory
        configsvr_requests_cpu       = each.value.dbaas_resource_config.configsvr_requests_cpu
        configsvr_requests_memory    = each.value.dbaas_resource_config.configsvr_requests_memory
        configsvr_storage            = each.value.dbaas_resource_config.configsvr_storage
        mongos_size                  = each.value.dbaas_resource_config.mongos_size
        mongos_limits_cpu            = each.value.dbaas_resource_config.mongos_limits_cpu
        mongos_limits_memory         = each.value.dbaas_resource_config.mongos_limits_memory
        mongos_requests_cpu          = each.value.dbaas_resource_config.mongos_requests_cpu
        mongos_requests_memory       = each.value.dbaas_resource_config.mongos_requests_memory
        dbdeploy_name_prefix         = each.value.external_resource_config.dbdeploy_name_prefix
        db_username                  = each.value.external_resource_config.username
        management_policy            = each.value.dbaas_resource_config.management_policy
        image                        = each.value.dbaas_resource_config.image
        db_secret_key                = each.value.external_resource_config.master_user_password_secret_key
        cloud_region                 = var.cloud_region
        cc_name                      = var.cc_name
        dns_zone_id                  = var.private_dns_zone_id
        dns_name                     = "${var.cluster_name}-${each.value.externalservice_name}-external.${var.dbaas_subdomain}"
        istio_nb_egress_waypoint_name   = var.istio_nb_egress_waypoint_name
        istio_nb_egress_waypoint_namespace = var.istio_nb_egress_waypoint_namespace
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
        consumer_app_secret          = local.ca_bundle_secrets_by_monolith[each.key]
        ca_bundle_url                = each.value.external_resource_config.ca_bundle_url
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
        parameters                    = jsonencode(each.value.external_resource_config.parameters)
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
        snapshot_identifier          = each.value.external_resource_config.snapshot_identifier
  })
  filename = "${local.stateful_resources_output_path}/db-cluster-${each.key}.yaml"
}

resource "local_file" "monolith-db-monitoring" {
  for_each = { for key, stateful_resource in local.monolith_resources_to_monitor : key => stateful_resource }
  content = templatefile("${local.stateful_resources_template_path}/monolith-db-monitoring.yaml.tpl",
    {
        cluster_name                 = "${var.cc_name}-${var.cluster_name}-${each.value.external_resource_config.dbdeploy_name_prefix}"
        namespace                    = each.value.resource_namespace
        externalservice_name         = each.value.externalservice_name
        db_secret                    = each.value.external_resource_config.master_user_password_secret
        db_secret_key                = each.value.external_resource_config.master_user_password_secret_key
        port                         = each.value.external_resource_config.port
        db_username                  = each.value.external_resource_config.username
        ca_bundle_secret_key         = each.value.ca_bundle_secret.key
        ca_bundle_secret_name        = each.value.ca_bundle_secret.name
  })
  filename = "${local.stateful_resources_output_path}/monolith-db-monitoring-${each.key}.yaml"
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
  helm_stateful_resources_resolved    = { for key, resource in local.helm_stateful_resources : key => merge(resource, {
    local_helm_config = merge(resource.local_helm_config, {
      resource_helm_repo = startswith(resource.local_helm_config.resource_helm_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", resource.local_helm_config.resource_helm_repo)) ? try("${var.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", resource.local_helm_config.resource_helm_repo)[0]]}${regex("(oci://[^/]+)(.*)", resource.local_helm_config.resource_helm_repo)[1]}", resource.local_helm_config.resource_helm_repo) : try(var.helm_proxy_repos_map[resource.local_helm_config.resource_helm_repo], resource.local_helm_config.resource_helm_repo)
    })
  })}
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
  external_name_map                   = merge(local.local_operator_external_name_map, local.local_external_name_map) # mutually exclusive maps

  # managed_resource_password_map = { for key, stateful_resource in local.managed_stateful_resources : key => {
  #   vault_path  = "${var.kv_path}/${var.cluster_name}/${stateful_resource.external_resource_config.password_key_name}"
  #   namespaces  = stateful_resource.logical_service_config.secret_extra_namespaces
  #   secret_name = stateful_resource.logical_service_config.user_password_secret
  #   secret_key  = stateful_resource.logical_service_config.user_password_secret_key
  #   }
  # }

  monolith_env_vpc_child_databases = { for key, managed_resource in local.managed_stateful_resources : key => managed_resource if var.managed_svc_as_monolith == true }

  monolith_env_vpc_resource_password_map = { for key, stateful_resource in local.monolith_env_vpc_child_databases : key => {
    namespaces  = stateful_resource.logical_service_config.secret_extra_namespaces
    secret_name = stateful_resource.logical_service_config.user_password_secret
    secret_key  = stateful_resource.logical_service_config.user_password_secret_key
    }
  }

  monolith_env_vpc_aws_db_resources =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "rds" || monolith_resource.provider == "documentdb"}
  monolith_env_vpc_aws_rds_resources =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "rds"}
  monolith_env_mysql_dbaas_resources  =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "dbaas" && monolith_resource.resource_type == "mysql" }
  monolith_env_mongo_dbaas_resources  =  { for key, monolith_resource in var.monolith_stateful_resources : key => monolith_resource if monolith_resource.provider == "dbaas" && monolith_resource.resource_type == "mongodb" }
  monolith_resources_to_monitor = merge(local.monolith_env_vpc_aws_rds_resources, local.monolith_env_mysql_dbaas_resources)

  monolith_managed_password_map = { for key, stateful_resource in var.monolith_stateful_resources : key => {
    vault_path  = "${var.kv_path}/${var.cluster_name}/${stateful_resource.external_resource_config.password_key_name}"
    namespace   = stateful_resource.external_resource_config.master_user_password_secret_namespace
    secret_name = stateful_resource.external_resource_config.master_user_password_secret
    secret_key  = stateful_resource.external_resource_config.master_user_password_secret_key
    }
  }

  monolith_init_mysql_managed_stateful_resources   = { for key, resource in local.mysql_managed_stateful_resources : key => resource if var.managed_svc_as_monolith == true }
  monolith_init_mongodb_managed_stateful_resources = { for key, resource in local.mongodb_managed_stateful_resources : key => resource if var.managed_svc_as_monolith == true }

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

  consumer_app_replica_externalname_services = {
    for db_server in distinct([
      for _, resource in local.managed_stateful_resources :
      resource.monolith_db_server if resource.enabled
    ]) :
    db_server => [
      for _, resource in local.managed_stateful_resources :
      resource.logical_service_config.logical_replica_service_name
      if resource.monolith_db_server == db_server && resource.enabled
    ]
  }

  ca_bundle_secrets_by_monolith = {
    for monolith_key, monolith in var.monolith_stateful_resources : monolith_key => {
      ca_bundle_secret = monolith.ca_bundle_secret.name
      ca_bundle_secret_key = monolith.ca_bundle_secret.key
      namespaces = distinct(
        concat(
          # From all services referencing this monolith
          flatten([
            for key, resource in local.managed_stateful_resources : (
              resource.monolith_db_server == monolith_key ?
              resource.logical_service_config.secret_extra_namespaces :
              []
            )
          ]),
          [monolith.resource_namespace]
        )
      )
    }
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

  percona_credentials_secret_provider_key = "percona_bucket_access_key_id"
  percona_credentials_id_provider_key     = "percona_bucket_access_key_id"

  strimzi_kafka_grafana_dashboards_version = "0.41.0"
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

variable "private_dns_zone_id" {
  type        = string
  description = "The ID of the private DNS zone for the environment."
}

variable "istio_nb_egress_waypoint_name" {
  type        = string
  description = "Name of the Istio egress waypoint"
  default     = "egress-waypoint"
}

variable "istio_nb_egress_waypoint_namespace" {
  type        = string
  description = "Namespace of the Istio egress waypoint"
  default     = "istio-system"
}

variable "dbaas_subdomain" {
  type        = string
  description = "The subdomain for the DBaaS services."
  default     = "storage"
}

variable "namespace_meta" {
  type = any
  description = "Metadata for the namespaces"
}

variable "helm_proxy_repos_map" {
  type        = map(string)
  description = "Map of original Helm repository URLs to proxy repository URLs"
}
