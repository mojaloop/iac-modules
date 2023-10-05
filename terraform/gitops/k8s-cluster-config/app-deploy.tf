module "mojaloop" {
  count                                = var.mojaloop_enabled ? 1 : 0
  source                               = "../mojaloop"
  nat_public_ips                       = var.nat_public_ips
  internal_load_balancer_dns           = var.internal_load_balancer_dns
  external_load_balancer_dns           = var.external_load_balancer_dns
  private_subdomain                    = var.private_subdomain
  public_subdomain                     = var.public_subdomain
  external_interop_switch_fqdn         = var.external_interop_switch_fqdn
  internal_interop_switch_fqdn         = var.internal_interop_switch_fqdn
  secrets_key_map                      = var.secrets_key_map
  properties_key_map                   = var.properties_key_map
  mojaloop_chart_version               = var.mojaloop_chart_version
  mcm_enabled                          = var.mcm_enabled
  mcm_chart_version                    = var.mcm_chart_version
  mojaloop_enabled                     = var.mojaloop_enabled
  bulk_enabled                         = var.bulk_enabled
  third_party_enabled                  = var.third_party_enabled
  output_dir                           = var.output_dir
  gitlab_project_url                   = var.gitlab_project_url
  cluster_name                         = var.cluster_name
  stateful_resources_config_file       = var.mojaloop_stateful_resources_config_file
  current_gitlab_project_id            = var.current_gitlab_project_id
  gitlab_group_name                    = var.gitlab_group_name
  gitlab_api_url                       = var.gitlab_api_url
  gitlab_server_url                    = var.gitlab_server_url
  kv_path                              = var.kv_path
  private_network_cidr                 = var.private_network_cidr
  cert_manager_service_account_name    = var.cert_manager_service_account_name
  istio_namespace                      = var.istio_namespace
  nginx_external_namespace             = var.nginx_external_namespace
  keycloak_fqdn                        = local.keycloak_fqdn
  vault_namespace                      = var.vault_namespace
  cert_manager_namespace               = var.cert_manager_namespace
  mcm_oidc_client_secret_secret_key    = var.mcm_oidc_client_secret_secret_key
  mcm_oidc_client_secret_secret        = var.mcm_oidc_client_secret_secret
  jwt_client_secret_secret_key         = var.jwt_client_secret_secret_key
  jwt_client_secret_secret             = var.jwt_client_secret_secret
  default_ssl_certificate              = var.default_ssl_certificate
}

/* module "pm4ml" {
  count = var.pm4ml_enabled ? 1 : 0
  source = "../pm4ml"
  
} */

variable "mojaloop_stateful_resources_config_file" {
  default     = "../config/mojaloop-stateful-resources.json"
  type        = string
  description = "where to pull stateful resources config for mojaloop"
}

variable "mojaloop_enabled" {
  description = "whether mojaloop app is enabled or not"
  type        = bool
  default     = true
}

variable "mojaloop_chart_version" {
  description = "Mojaloop version to install via Helm"
}

variable "mcm_enabled" {
  description = "whether mcm app is enabled or not"
  type        = bool
  default     = true
}

variable "pm4ml_enabled" {
  description = "whether pm4ml app is enabled or not"
  type        = bool
  default     = true
}

variable "mcm_chart_version" {
  description = "mcm version to install via Helm"
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

variable "private_network_cidr" {
  description = "network cidr for private network"
  type        = string
}

variable "mcm_oidc_client_secret_secret_key" {
  type = string
  default = "value"
}
variable "mcm_oidc_client_secret_secret" {
  type = string
  default = "value"
}
variable "jwt_client_secret_secret_key" {
  type = string
  default = "value"
}
variable "jwt_client_secret_secret" {
  type = string
  default = "value"
}

locals {
  mojaloop_keycloak_realm_env_secret_map = {
    "${var.mcm_oidc_client_secret_secret}" = var.mcm_oidc_client_secret_secret_key
    "${var.jwt_client_secret_secret}" = var.jwt_client_secret_secret_key
  }
  keycloak_realm_env_secret_map = var.mojaloop_enabled ? local.mojaloop_keycloak_realm_env_secret_map : {}
}