module "generate_pm4ml_files" {
  source = "../generate-files"
  var_map = {
    pm4ml_enabled                        = var.pm4ml_enabled
    gitlab_project_url                   = var.gitlab_project_url
    pm4ml_chart_repo                     = var.pm4ml_chart_repo
    pm4ml_chart_version                  = var.pm4ml_chart_version
    pm4ml_release_name                   = var.pm4ml_release_name
    pm4ml_namespace                      = var.pm4ml_namespace
    storage_class_name                   = var.storage_class_name
    pm4ml_sync_wave                      = var.pm4ml_sync_wave
    external_load_balancer_dns           = var.external_load_balancer_dns
    istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
    istio_internal_gateway_namespace     = var.istio_internal_gateway_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    pm4ml_wildcard_gateway               = local.pm4ml_wildcard_gateway
    keycloak_fqdn                        = local.keycloak_fqdn
    keycloak_dfsp_realm_name             = var.keycloak_dfsp_realm_name

  }
  file_list       = ["istio-gateway.yaml", "keycloak-realm-cr.yaml", "kustomization.yaml", "values-pm4ml.yaml", "values-secret.yaml"]
  template_path   = "${path.module}/../generate-files/templates/pm4ml"
  output_path     = "${var.output_dir}/pm4ml"
  app_file        = "pm4ml-app.yaml"
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
  pm4ml_wildcard_gateway                       = var.pm4ml_ingress_internal_lb ? "internal" : "external"
}

variable "pm4ml_enabled" {
  description = "whether pm4ml app is enabled or not"
  type        = bool
  default     = true
}

resource "tls_private_key" "jws" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

variable "pm4ml_ingress_internal_lb" {
  type        = bool
  description = "pm4ml_ingress_internal_lb"
  default     = true
}

variable "pm4ml_chart_repo" {
  description = "repo for pm4ml charts"
  type        = string
  default     = "https://pm4ml.github.io/mojaloop-payment-manager-helm/repo"
}

variable "pm4ml_namespace" {
  description = "namespace for pm4ml release"
  type        = string
  default     = "pm4ml"
}

variable "pm4ml_release_name" {
  description = "name for pm4ml release"
  type        = string
  default     = "pm4ml"
}

variable "pm4ml_chart_version" {
  description = "pm4ml version to install via Helm"
}

variable "pm4ml_sync_wave" {
  type        = string
  description = "pm4ml_sync_wave"
  default     = "0"
}
