module "generate_mojaloop_files" {
  source = "../generate-files"
  var_map = {
    mojaloop_enabled                                                  = var.mojaloop_enabled
    gitlab_project_url                                                = var.gitlab_project_url
    mojaloop_chart_repo                                               = var.mojaloop_chart_repo
    mojaloop_chart_version                                            = try(var.app_var_map.mojaloop_chart_version, var.mojaloop_chart_version)
    mojaloop_release_name                                             = var.mojaloop_release_name
    mojaloop_namespace                                                = var.mojaloop_namespace
    storage_class_name                                                = var.storage_class_name
    mojaloop_sync_wave                                                = var.mojaloop_sync_wave
    mojaloop_test_sync_wave                                           = var.mojaloop_test_sync_wave
    internal_ttk_enabled                                              = var.internal_ttk_enabled
    ttk_test_currency1                                                = var.ttk_test_currency1
    ttk_test_currency2                                                = var.ttk_test_currency2
    ttk_test_currency3                                                = var.ttk_test_currency3
    internal_sim_enabled                                              = var.internal_sim_enabled
    mojaloop_thirdparty_support_enabled                               = var.third_party_enabled
    bulk_enabled                                                      = var.bulk_enabled
    ttksims_enabled                                                   = var.ttksims_enabled
    jws_signing_priv_key                                              = tls_private_key.jws.private_key_pem
    ingress_subdomain                                                 = var.public_subdomain
    quoting_service_simple_routing_mode_enabled                       = var.quoting_service_simple_routing_mode_enabled
    central_ledger_handler_transfer_position_batch_processing_enabled = try(var.app_var_map.central_ledger_handler_transfer_position_batch_processing_enabled, false)
    central_ledger_handler_transfer_position_batch_size               = try(var.app_var_map.central_ledger_handler_transfer_position_batch_size, 100)
    central_ledger_handler_transfer_position_batch_consume_timeout_ms = try(var.app_var_map.central_ledger_handler_transfer_position_batch_consume_timeout_ms, 10)
    central_ledger_cache_enabled                                      = try(var.app_var_map.central_ledger_cache_enabled, true)
    central_ledger_cache_expires_in_ms                                = try(var.app_var_map.central_ledger_cache_expires_in_ms, 1000)
    interop_switch_fqdn                                               = var.external_interop_switch_fqdn
    int_interop_switch_fqdn                                           = var.internal_interop_switch_fqdn
    external_ingress_class_name                                       = var.external_ingress_class_name
    vault_certman_secretname                                          = var.vault_certman_secretname
    nginx_jwt_namespace                                               = var.nginx_jwt_namespace
    ingress_class_name                                                = var.mojaloop_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways                                     = var.istio_create_ingress_gateways
    istio_external_gateway_name                                       = var.istio_external_gateway_name
    external_load_balancer_dns                                        = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name                              = var.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace                                  = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name                              = var.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace                                  = var.istio_external_gateway_namespace
    mojaloop_wildcard_gateway                                         = local.mojaloop_wildcard_gateway
    keycloak_fqdn                                                     = var.keycloak_fqdn
    keycloak_realm_name                                               = var.keycloak_hubop_realm_name
    ttk_frontend_public_fqdn                                          = var.ttk_frontend_public_fqdn
    ttk_backend_public_fqdn                                           = var.ttk_backend_public_fqdn
    kafka_host                                                        = "${local.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kafka_port                                                        = local.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_port
    account_lookup_db_existing_secret                                 = local.stateful_resources[local.ml_als_resource_index].logical_service_config.user_password_secret
    account_lookup_db_user                                            = local.stateful_resources[local.ml_als_resource_index].logical_service_config.username
    account_lookup_db_host                                            = "${local.stateful_resources[local.ml_als_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    account_lookup_db_port                                            = local.stateful_resources[local.ml_als_resource_index].logical_service_config.logical_service_port
    account_lookup_db_database                                        = local.stateful_resources[local.ml_als_resource_index].logical_service_config.database_name
    central_ledger_db_existing_secret                                 = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    central_ledger_db_user                                            = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    central_ledger_db_host                                            = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    central_ledger_db_port                                            = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    central_ledger_db_database                                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    central_settlement_db_existing_secret                             = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    central_settlement_db_user                                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    central_settlement_db_host                                        = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    central_settlement_db_port                                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    central_settlement_db_database                                    = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    quoting_db_existing_secret                                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    quoting_db_user                                                   = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    quoting_db_host                                                   = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    quoting_db_port                                                   = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    quoting_db_database                                               = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    cep_mongodb_database                                              = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.database_name
    cep_mongodb_user                                                  = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.username
    cep_mongodb_host                                                  = "${local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    cep_mongodb_existing_secret                                       = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.user_password_secret
    cep_mongodb_port                                                  = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.logical_service_port
    cl_mongodb_database                                               = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.database_name
    cl_mongodb_user                                                   = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.username
    cl_mongodb_host                                                   = "${local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    cl_mongodb_existing_secret                                        = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.user_password_secret
    cl_mongodb_port                                                   = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.logical_service_port
    ttk_mongodb_database                                              = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.database_name
    ttk_mongodb_user                                                  = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.username
    ttk_mongodb_host                                                  = "${local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    ttk_mongodb_existing_secret                                       = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.user_password_secret
    ttk_mongodb_port                                                  = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.logical_service_port
    third_party_consent_db_existing_secret                            = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.user_password_secret
    third_party_consent_db_user                                       = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.username
    third_party_consent_db_host                                       = "${local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_consent_db_port                                       = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.logical_service_port
    third_party_consent_db_database                                   = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.database_name
    third_party_auth_db_existing_secret                               = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.user_password_secret
    third_party_auth_db_user                                          = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.username
    third_party_auth_db_host                                          = "${local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_auth_db_port                                          = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.logical_service_port
    third_party_auth_db_database                                      = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.database_name
    third_party_auth_redis_host                                       = "${local.stateful_resources[local.third_party_redis_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_auth_redis_port                                       = local.stateful_resources[local.third_party_redis_resource_index].logical_service_config.logical_service_port
    ttksims_redis_host                                                = "${local.stateful_resources[local.ttk_redis_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    ttksims_redis_port                                                = local.stateful_resources[local.ttk_redis_resource_index].logical_service_config.logical_service_port
    account_lookup_service_replica_count                              = try(var.app_var_map.account_lookup_service_replica_count, 1)
    account_lookup_service_admin_replica_count                        = try(var.app_var_map.account_lookup_service_admin_replica_count, 1)
    quoting_service_replica_count                                     = try(var.app_var_map.quoting_service_replica_count, 1)
    quoting_service_handler_replica_count                             = try(var.app_var_map.quoting_service_handler_replica_count, 1)
    ml_api_adapter_service_replica_count                              = try(var.app_var_map.ml_api_adapter_service_replica_count, 1)
    ml_api_adapter_handler_notifications_replica_count                = try(var.app_var_map.ml_api_adapter_handler_notifications_replica_count, 1)
    central_ledger_service_replica_count                              = try(var.app_var_map.central_ledger_service_replica_count, 1)
    central_ledger_handler_transfer_prepare_replica_count             = try(var.app_var_map.central_ledger_handler_transfer_prepare_replica_count, 1)
    central_ledger_handler_transfer_position_replica_count            = try(var.app_var_map.central_ledger_handler_transfer_position_replica_count, 1)
    central_ledger_handler_transfer_position_batch_replica_count      = try(var.app_var_map.central_ledger_handler_transfer_position_batch_replica_count, 1)
    central_ledger_handler_transfer_get_replica_count                 = try(var.app_var_map.central_ledger_handler_transfer_get_replica_count, 1)
    central_ledger_handler_transfer_fulfil_replica_count              = try(var.app_var_map.central_ledger_handler_transfer_fulfil_replica_count, 1)
    central_ledger_handler_admin_transfer_replica_count               = try(var.app_var_map.central_ledger_handler_admin_transfer_replica_count, 1)
    central_settlement_service_replica_count                          = try(var.app_var_map.central_settlement_service_replica_count, 1)
    central_settlement_handler_deferredsettlement_replica_count       = try(var.app_var_map.central_settlement_handler_deferredsettlement_replica_count, 1)
    central_settlement_handler_grosssettlement_replica_count          = try(var.app_var_map.central_settlement_handler_grosssettlement_replica_count, 1)
    central_settlement_handler_rules_replica_count                    = try(var.app_var_map.central_settlement_handler_rules_replica_count, 1)
    trasaction_requests_service_replica_count                         = try(var.app_var_map.trasaction_requests_service_replica_count, 1)
    auth_service_replica_count                                        = try(var.app_var_map.auth_service_replica_count, 1)
    consent_oracle_replica_count                                      = try(var.app_var_map.consent_oracle_replica_count, 1)
    tp_api_svc_replica_count                                          = try(var.app_var_map.tp_api_svc_replica_count, 1)
    bulk_api-adapter_service_replica_count                            = try(var.app_var_map.adapter_service_replica_count, 1)
    bulk_api_adapter_handler_notification_replica_count               = try(var.app_var_map.bulk_api_adapter_handler_notification_replica_count, 1)
    cl_handler_bulk_transfer_prepare_replica_count                    = try(var.app_var_map.cl_handler_bulk_transfer_prepare_replica_count, 1)
    cl_handler_bulk_transfer_fulfil_replica_count                     = try(var.app_var_map.cl_handler_bulk_transfer_fulfil_replica_count, 1)
    cl_handler_bulk_transfer_processing_replica_count                 = try(var.app_var_map.cl_handler_bulk_transfer_processing_replica_count, 1)
    cl_handler_bulk_transfer_get_replica_count                        = try(var.app_var_map.cl_handler_bulk_transfer_get_replica_count, 1)
    enable_istio_injection                                            = try(var.app_var_map.enable_istio_injection, false)
    account_lookup_service_affinity                                   = yamlencode(var.app_var_map.workload_definitions.account_lookup_service.affinity_definition)
    account_lookup_admin_service_affinity                             = try(yamlencode(var.app_var_map.workload_definitions.account_lookup_service.affinity_definition), null)
    quoting_service_affinity                                          = try(yamlencode(var.app_var_map.workload_definitions.quoting_service.affinity_definition), null)
    ml_api_adapter_service_affinity                                   = try(yamlencode(var.app_var_map.workload_definitions.core_api_adapters.affinity_definition), null)
    ml_api_adapter_handler_notifications_affinity                     = try(yamlencode(var.app_var_map.workload_definitions.core_api_adapters.affinity_definition), null)
    centralledger_service_affinity                                    = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_transfer_prepare_affinity                  = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_transfer_position_affinity                 = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_transfer_position_batch_affinity           = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_transfer_get_affinity                      = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_transfer_fulfil_affinity                   = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_ledger_handler_admin_transfer_affinity                    = try(yamlencode(var.app_var_map.workload_definitions.central_ledger_service.affinity_definition), null)
    central_settlement_service_affinity                               = try(yamlencode(var.app_var_map.workload_definitions.central_settlement.affinity_definition), null)
    central_settlement_handler_deferredsettlement_affinity            = try(yamlencode(var.app_var_map.workload_definitions.central_settlement.affinity_definition), null)
    central_settlement_handler_grosssettlement_affinity               = try(yamlencode(var.app_var_map.workload_definitions.central_settlement.affinity_definition), null)
    central_settlement_handler_rules_affinity                         = try(yamlencode(var.app_var_map.workload_definitions.central_settlement.affinity_definition), null)
    trasaction_requests_service_affinity                              = try(yamlencode(var.app_var_map.workload_definitions.core_api_adapters.affinity_definition), null)
    central_ledger_monitoring_prefix                                  = try(var.app_var_map.central_ledger_monitoring_prefix, "moja_cl_")
    quoting_service_monitoring_prefix                                 = try(var.app_var_map.quoting_service_monitoring_prefix, "moja_qs_")
    ml_api_adapter_monitoring_prefix                                  = try(var.app_var_map.ml_api_adapter_monitoring_prefix, "moja_ml_")
    account_lookup_service_monitoring_prefix                          = try(var.app_var_map.account_lookup_service_monitoring_prefix, "moja_als_")
    grafana_dashboard_tag                                             = try(var.app_var_map.grafana_dashboard_tag, var.mojaloop_chart_version)
    bof_release_name                                                  = var.bof_release_name
    ory_namespace                                                     = var.ory_namespace
    bof_role_perm_operator_host                                       = "${var.bof_release_name}-security-role-perm-operator-svc.${var.ory_namespace}.svc.cluster.local"
    auth_fqdn                                                         = var.auth_fqdn
    central_admin_host                                                = "${var.mojaloop_release_name}-centralledger-service"
    central_settlements_host                                          = "${var.mojaloop_release_name}-centralsettlement-service"
    account_lookup_service_host                                       = "${var.mojaloop_release_name}-account-lookup-service"
    reporting_db_secret_name                                          = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    reporting_db_user                                                 = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    reporting_db_host                                                 = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    reporting_db_port                                                 = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    reporting_db_database                                             = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    reporting_db_secret_key                                           = "mysql-password"
    reporting_events_mongodb_database                                 = local.stateful_resources[local.reporting_events_mongodb_resource_index].logical_service_config.database_name
    reporting_events_mongodb_user                                     = local.stateful_resources[local.reporting_events_mongodb_resource_index].logical_service_config.username
    reporting_events_mongodb_host                                     = "${local.stateful_resources[local.reporting_events_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    reporting_events_mongodb_existing_secret                          = local.stateful_resources[local.reporting_events_mongodb_resource_index].logical_service_config.user_password_secret
    reporting_events_mongodb_port                                     = local.stateful_resources[local.reporting_events_mongodb_resource_index].logical_service_config.logical_service_port
    keto_read_url                                                     = "http://keto-read.${var.ory_namespace}.svc.cluster.local:80"
    keto_write_url                                                    = "http://keto-write.${var.ory_namespace}.svc.cluster.local:80"
    kratos_service_name                                               = "kratos-public.${var.ory_namespace}.svc.cluster.local"
    portal_fqdn                                                       = var.finance_portal_fqdn
    finance_portal_release_name                                       = "fin-portal"
    finance_portal_chart_version                                      = try(var.app_var_map.finance_portal_chart_version, var.finance_portal_chart_version)
    ory_stack_enabled                                                 = var.ory_stack_enabled
    oathkeeper_auth_provider_name                                     = var.oathkeeper_auth_provider_name
    role_assign_service_secret_key                                    = var.hubop_realm_role_assign_service_secret_key
    role_assign_service_secret                                        = var.hubop_realm_role_assign_service_secret
    role_assign_service_user                                          = var.hubop_realm_role_assign_service_user
    keycloak_dfsp_realm_name                                          = var.keycloak_dfsp_realm_name
    apiResources                                                      = local.apiResources
    reporting_templates_chart_version                                 = try(var.app_var_map.reporting_templates_chart_version, var.reporting_templates_chart_version)
    ttk_gp_testcase_labels                                            = try(var.app_var_map.ttk_gp_testcase_labels, var.ttk_gp_testcase_labels)
  }
  file_list       = [for f in fileset(local.mojaloop_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.mojaloop_app_file, f))]
  template_path   = local.mojaloop_template_path
  output_path     = "${var.output_dir}/mojaloop"
  app_file        = local.mojaloop_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}


locals {
  mojaloop_template_path                       = "${path.module}/../generate-files/templates/mojaloop"
  mojaloop_app_file                            = "mojaloop-app.yaml"
  ml_als_resource_index                        = index(local.stateful_resources.*.resource_name, "account-lookup-db")
  ml_cl_resource_index                         = index(local.stateful_resources.*.resource_name, "central-ledger-db")
  bulk_mongodb_resource_index                  = index(local.stateful_resources.*.resource_name, "bulk-mongodb")
  ttk_mongodb_resource_index                   = index(local.stateful_resources.*.resource_name, "ttk-mongodb")
  cep_mongodb_resource_index                   = index(local.stateful_resources.*.resource_name, "cep-mongodb")
  mojaloop_kafka_resource_index                = index(local.stateful_resources.*.resource_name, "mojaloop-kafka")
  third_party_redis_resource_index             = index(local.stateful_resources.*.resource_name, "thirdparty-auth-svc-redis")
  third_party_auth_db_resource_index           = index(local.stateful_resources.*.resource_name, "thirdparty-auth-svc-db")
  third_party_consent_oracle_db_resource_index = index(local.stateful_resources.*.resource_name, "mysql-consent-oracle-db")
  ttk_redis_resource_index                     = index(local.stateful_resources.*.resource_name, "ttk-redis")
  reporting_events_mongodb_resource_index      = index(local.stateful_resources.*.resource_name, "reporting-events-mongodb")
  mojaloop_wildcard_gateway                    = var.mojaloop_ingress_internal_lb ? "internal" : "external"
  apiResources                                 = yamldecode(file(var.rbac_api_resources_file))
}

variable "app_var_map" {
  type = any
}
variable "mojaloop_enabled" {
  description = "whether mojaloop app is enabled or not"
  type        = bool
  default     = true
}

resource "tls_private_key" "jws" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

variable "mojaloop_ingress_internal_lb" {
  type        = bool
  description = "mojaloop_ingress_internal_lb"
  default     = true
}

variable "mojaloop_chart_repo" {
  description = "repo for mojaloop charts"
  type        = string
  default     = "https://mojaloop.github.io/helm/repo"
}

variable "mojaloop_namespace" {
  description = "namespace for mojaloop release"
  type        = string
  default     = "mojaloop"
}

variable "mojaloop_release_name" {
  description = "name for mojaloop release"
  type        = string
  default     = "moja"
}

variable "mojaloop_chart_version" {
  description = "Mojaloop version to install via Helm"
}

variable "finance_portal_chart_version" {
  description = "finance portal chart version"
  default     = "4.2.3"
}

variable "mojaloop_sync_wave" {
  type        = string
  description = "mojaloop_sync_wave"
  default     = "0"
}

variable "mojaloop_test_sync_wave" {
  type        = string
  description = "mojaloop_sync_wave"
  default     = "1"
}

variable "internal_ttk_enabled" {
  description = "whether internal ttk instance is enabled or not"
  default     = true
}

variable "ttk_test_currency1" {
  description = "Test currency for TTK GP tests"
  type        = string
  default     = "EUR"
}

variable "ttk_test_currency2" {
  description = "Test currency2 for TTK GP tests"
  type        = string
  default     = "USD"
}

variable "ttk_test_currency3" {
  description = "Test cgs currency for TTK GP tests"
  type        = string
  default     = "CAD"
}

variable "internal_sim_enabled" {
  description = "whether internal mojaloop simulators ar enabled or not"
  default     = true
}

variable "third_party_enabled" {
  description = "whether third party apis are enabled or not"
  type        = bool
  default     = false
}

variable "bulk_enabled" {
  description = "whether bulk is enabled or not"
  type        = bool
  default     = false
}

variable "ttksims_enabled" {
  description = "whether ttksims are enabled or not"
  type        = bool
  default     = false
}

variable "quoting_service_simple_routing_mode_enabled" {
  description = "whether buquoting_service_simple_routing_mode_enabled is enabled or not"
  type        = bool
  default     = false
}

variable "ttk_frontend_public_fqdn" {
  type = string
}
variable "ttk_backend_public_fqdn" {
  type = string
}

variable "auth_fqdn" {
  type = string
}
variable "ory_namespace" {
  type = string
}

variable "finance_portal_fqdn" {
  type = string
}

variable "bof_release_name" {
  type = string
}
variable "ory_stack_enabled" {
  type = bool
}
variable "oathkeeper_auth_provider_name" {
  type = string
}
variable "keycloak_hubop_realm_name" {
  type        = string
  description = "name of realm for hub operator api access"
}
variable "hubop_realm_role_assign_service_secret" {
  type = string
}
variable "hubop_realm_role_assign_service_secret_key" {
  type = string
}
variable "hubop_realm_role_assign_service_user" {
  type = string
}

variable "rbac_api_resources_file" {
  type = string
}

variable "reporting_templates_chart_version" {
  type    = string
  default = "1.1.7"
}

variable "ttk_gp_testcase_labels" {
  type    = string
  default = "p2p"
}
