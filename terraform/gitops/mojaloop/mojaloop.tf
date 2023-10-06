module "generate_mojaloop_files" {
  source = "../generate-files"
  var_map = {
    mojaloop_enabled                              = var.mojaloop_enabled
    gitlab_project_url                            = var.gitlab_project_url
    mojaloop_chart_repo                           = var.mojaloop_chart_repo
    mojaloop_chart_version                        = var.mojaloop_chart_version
    mojaloop_release_name                         = var.mojaloop_release_name
    mojaloop_namespace                            = var.mojaloop_namespace
    storage_class_name                            = var.storage_class_name
    mojaloop_sync_wave                            = var.mojaloop_sync_wave
    mojaloop_test_sync_wave                       = var.mojaloop_test_sync_wave
    internal_ttk_enabled                          = var.internal_ttk_enabled
    ttk_test_currency1                            = var.ttk_test_currency1
    ttk_test_currency2                            = var.ttk_test_currency2
    ttk_test_currency3                            = var.ttk_test_currency3
    internal_sim_enabled                          = var.internal_sim_enabled
    mojaloop_thirdparty_support_enabled           = var.third_party_enabled
    bulk_enabled                                  = var.bulk_enabled
    ttksims_enabled                               = var.ttksims_enabled
    jws_signing_priv_key                          = tls_private_key.jws.private_key_pem
    ingress_subdomain                             = var.public_subdomain
    quoting_service_simple_routing_mode_enabled   = var.quoting_service_simple_routing_mode_enabled
    interop_switch_fqdn                           = var.external_interop_switch_fqdn
    int_interop_switch_fqdn                       = var.internal_interop_switch_fqdn
    external_ingress_class_name                   = var.external_ingress_class_name
    vault_certman_secretname                      = var.vault_certman_secretname
    nginx_jwt_namespace                           = var.nginx_jwt_namespace
    ingress_class_name                            = var.mojaloop_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    istio_create_ingress_gateways                 = var.istio_create_ingress_gateways
    istio_external_gateway_name                   = var.istio_external_gateway_name
    external_load_balancer_dns                    = var.external_load_balancer_dns
    istio_internal_mojaloop_wildcard_gateway_name = local.istio_internal_mojaloop_wildcard_gateway_name
    istio_internal_gateway_namespace              = var.istio_internal_gateway_namespace
    istio_external_mojaloop_wildcard_gateway_name = local.istio_external_mojaloop_wildcard_gateway_name
    istio_external_gateway_namespace              = var.istio_external_gateway_namespace
    mojaloop_wildcard_gateway                     = local.mojaloop_wildcard_gateway
    keycloak_fqdn                                 = var.keycloak_fqdn
    keycloak_dfsp_realm_name                      = var.keycloak_dfsp_realm_name
    kafka_host                                    = "${local.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kafka_port                                    = local.stateful_resources[local.mojaloop_kafka_resource_index].logical_service_config.logical_service_port
    account_lookup_db_existing_secret             = local.stateful_resources[local.ml_als_resource_index].logical_service_config.user_password_secret
    account_lookup_db_user                        = local.stateful_resources[local.ml_als_resource_index].logical_service_config.username
    account_lookup_db_host                        = "${local.stateful_resources[local.ml_als_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    account_lookup_db_port                        = local.stateful_resources[local.ml_als_resource_index].logical_service_config.logical_service_port
    account_lookup_db_database                    = local.stateful_resources[local.ml_als_resource_index].logical_service_config.database_name
    central_ledger_db_existing_secret             = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    central_ledger_db_user                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    central_ledger_db_host                        = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    central_ledger_db_port                        = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    central_ledger_db_database                    = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    central_settlement_db_existing_secret         = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    central_settlement_db_user                    = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    central_settlement_db_host                    = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    central_settlement_db_port                    = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    central_settlement_db_database                = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    quoting_db_existing_secret                    = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.user_password_secret
    quoting_db_user                               = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.username
    quoting_db_host                               = "${local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    quoting_db_port                               = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.logical_service_port
    quoting_db_database                           = local.stateful_resources[local.ml_cl_resource_index].logical_service_config.database_name
    cep_mongodb_database                          = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.database_name
    cep_mongodb_user                              = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.username
    cep_mongodb_host                              = "${local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    cep_mongodb_existing_secret                   = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.user_password_secret
    cep_mongodb_port                              = local.stateful_resources[local.cep_mongodb_resource_index].logical_service_config.logical_service_port
    cl_mongodb_database                           = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.database_name
    cl_mongodb_user                               = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.username
    cl_mongodb_host                               = "${local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    cl_mongodb_existing_secret                    = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.user_password_secret
    cl_mongodb_port                               = local.stateful_resources[local.bulk_mongodb_resource_index].logical_service_config.logical_service_port
    ttk_mongodb_database                          = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.database_name
    ttk_mongodb_user                              = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.username
    ttk_mongodb_host                              = "${local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    ttk_mongodb_existing_secret                   = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.user_password_secret
    ttk_mongodb_port                              = local.stateful_resources[local.ttk_mongodb_resource_index].logical_service_config.logical_service_port
    third_party_consent_db_existing_secret        = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.user_password_secret
    third_party_consent_db_user                   = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.username
    third_party_consent_db_host                   = "${local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_consent_db_port                   = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.logical_service_port
    third_party_consent_db_database               = local.stateful_resources[local.third_party_consent_oracle_db_resource_index].logical_service_config.database_name
    third_party_auth_db_existing_secret           = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.user_password_secret
    third_party_auth_db_user                      = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.username
    third_party_auth_db_host                      = "${local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_auth_db_port                      = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.logical_service_port
    third_party_auth_db_database                  = local.stateful_resources[local.third_party_auth_db_resource_index].logical_service_config.database_name
    third_party_auth_redis_host                   = "${local.stateful_resources[local.third_party_redis_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    third_party_auth_redis_port                   = local.stateful_resources[local.third_party_redis_resource_index].logical_service_config.logical_service_port
    ttksims_redis_host                            = "${local.stateful_resources[local.ttk_redis_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    ttksims_redis_port                            = local.stateful_resources[local.ttk_redis_resource_index].logical_service_config.logical_service_port
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "custom-resources/ext-ingress.yaml", "custom-resources/istio-gateway.yaml"]
  template_path   = "${path.module}/../generate-files/templates/mojaloop"
  output_path     = "${var.output_dir}/mojaloop"
  app_file        = "mojaloop-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}


locals {
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
  mojaloop_wildcard_gateway                    = var.mojaloop_ingress_internal_lb ? "internal" : "external"
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
  default     = "GBP"
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
