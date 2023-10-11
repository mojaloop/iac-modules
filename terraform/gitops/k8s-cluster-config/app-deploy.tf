module "mojaloop" {
  count                                = var.common_var_map.mojaloop_enabled ? 1 : 0
  source                               = "../mojaloop"
  nat_public_ips                       = var.nat_public_ips
  internal_load_balancer_dns           = var.internal_load_balancer_dns
  external_load_balancer_dns           = var.external_load_balancer_dns
  private_subdomain                    = var.private_subdomain
  public_subdomain                     = var.public_subdomain
  external_interop_switch_fqdn         = local.external_interop_switch_fqdn
  internal_interop_switch_fqdn         = local.internal_interop_switch_fqdn
  secrets_key_map                      = var.secrets_key_map
  properties_key_map                   = var.properties_key_map
  output_dir                           = var.output_dir
  gitlab_project_url                   = var.gitlab_project_url
  cluster_name                         = var.cluster_name
  current_gitlab_project_id            = var.current_gitlab_project_id
  gitlab_group_name                    = var.gitlab_group_name
  gitlab_api_url                       = var.gitlab_api_url
  gitlab_server_url                    = var.gitlab_server_url
  kv_path                              = var.kv_path
  private_network_cidr                 = var.private_network_cidr
  cert_manager_service_account_name    = var.cert_manager_service_account_name
  nginx_external_namespace             = var.nginx_external_namespace
  keycloak_fqdn                        = local.keycloak_fqdn
  keycloak_name                        = var.keycloak_name
  keycloak_namespace                   = var.keycloak_namespace
  vault_namespace                      = var.vault_namespace
  cert_manager_namespace               = var.cert_manager_namespace
  mcm_oidc_client_secret_secret_key    = var.mcm_oidc_client_secret_secret_key
  mcm_oidc_client_secret_secret        = var.mcm_oidc_client_secret_secret
  jwt_client_secret_secret_key         = var.jwt_client_secret_secret_key
  jwt_client_secret_secret             = var.jwt_client_secret_secret
  mcm_public_fqdn                      = local.mcm_public_fqdn
  ttk_backend_public_fqdn              = local.ttk_backend_public_fqdn
  ttk_frontend_public_fqdn             = local.ttk_frontend_public_fqdn
  istio_external_gateway_name          = var.istio_external_gateway_name
  istio_internal_gateway_name          = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
  mojaloop_chart_version               = var.app_var_map.mojaloop_chart_version
  mcm_enabled                          = var.common_var_map.mcm_enabled
  mcm_chart_version                    = var.app_var_map.mcm_chart_version
  mojaloop_enabled                     = var.common_var_map.mojaloop_enabled
  bulk_enabled                         = var.app_var_map.bulk_enabled
  third_party_enabled                  = var.app_var_map.third_party_enabled
  mojaloop_ingress_internal_lb         = var.app_var_map.mojaloop_ingress_internal_lb
  mcm_ingress_internal_lb              = var.app_var_map.mcm_ingress_internal_lb
  stateful_resources_config_file       = var.mojaloop_stateful_resources_config_file
  local_vault_kv_root_path             = local.local_vault_kv_root_path
  app_var_map                          = var.app_var_map
}

module "pm4ml" {
  count                                          = var.common_var_map.pm4ml_enabled ? 1 : 0
  source                                         = "../pm4ml"
  nat_public_ips                                 = var.nat_public_ips
  internal_load_balancer_dns                     = var.internal_load_balancer_dns
  external_load_balancer_dns                     = var.external_load_balancer_dns
  private_subdomain                              = var.private_subdomain
  public_subdomain                               = var.public_subdomain
  external_interop_switch_fqdn                   = local.external_interop_switch_fqdn
  internal_interop_switch_fqdn                   = local.internal_interop_switch_fqdn
  secrets_key_map                                = var.secrets_key_map
  properties_key_map                             = var.properties_key_map
  output_dir                                     = var.output_dir
  gitlab_project_url                             = var.gitlab_project_url
  cluster_name                                   = var.cluster_name
  current_gitlab_project_id                      = var.current_gitlab_project_id
  gitlab_group_name                              = var.gitlab_group_name
  gitlab_api_url                                 = var.gitlab_api_url
  gitlab_server_url                              = var.gitlab_server_url
  kv_path                                        = var.kv_path
  cert_manager_service_account_name              = var.cert_manager_service_account_name
  keycloak_fqdn                                  = local.keycloak_fqdn
  keycloak_name                                  = var.keycloak_name
  keycloak_namespace                             = var.keycloak_namespace
  vault_namespace                                = var.vault_namespace
  cert_manager_namespace                         = var.cert_manager_namespace
  pm4ml_oidc_client_secret_secret_key            = var.pm4ml_oidc_client_secret_secret_key
  pm4ml_oidc_client_secret_secret                = var.pm4ml_oidc_client_secret_secret
  jwt_client_secret_secret_key                   = var.jwt_client_secret_secret_key
  jwt_client_secret_secret                       = var.jwt_client_secret_secret
  istio_external_gateway_name                    = var.istio_external_gateway_name
  istio_internal_gateway_name                    = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name           = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name           = local.istio_internal_wildcard_gateway_name
  pm4ml_external_mcm_public_fqdn                 = var.app_var_map.pm4ml_external_mcm_public_fqdn
  pm4ml_ingress_internal_lb                      = var.app_var_map.pm4ml_ingress_internal_lb
  pm4ml_chart_version                            = var.app_var_map.pm4ml_chart_version
  pm4ml_external_switch_client_secret_vault_path = var.app_var_map.pm4ml_external_switch_client_secret_vault_path
  pm4ml_external_switch_client_id                = var.app_var_map.pm4ml_external_switch_client_id
  pm4ml_external_switch_oidc_url                 = var.app_var_map.pm4ml_external_switch_oidc_url
  local_vault_kv_root_path                       = local.local_vault_kv_root_path
  portal_fqdn                                    = local.portal_fqdn
  experience_api_fqdn                            = local.experience_api_fqdn
  mojaloop_connnector_fqdn                       = local.mojaloop_connnector_fqdn
}

variable "app_var_map" {
  type = any
}
variable "common_var_map" {
  type = any
}
variable "mojaloop_stateful_resources_config_file" {
  default     = "../config/mojaloop-stateful-resources.json"
  type        = string
  description = "where to pull stateful resources config for mojaloop"
}

variable "private_network_cidr" {
  description = "network cidr for private network"
  type        = string
}

variable "mcm_oidc_client_secret_secret_key" {
  type    = string
  default = "secret"
}
variable "mcm_oidc_client_secret_secret" {
  type    = string
  default = "mcm-oidc-client-secret"
}
variable "jwt_client_secret_secret_key" {
  type    = string
  default = "secret"
}
variable "jwt_client_secret_secret" {
  type    = string
  default = "jwt-oidc-client-secret"
}

variable "pm4ml_oidc_client_secret_secret_key" {
  type    = string
  default = "secret"
}
variable "pm4ml_oidc_client_secret_secret" {
  type    = string
  default = "pm4ml-oidc-client-secret"
}

locals {
  mojaloop_wildcard_gateway = var.app_var_map.mojaloop_ingress_internal_lb ? "internal" : "external"
  mcm_wildcard_gateway      = var.app_var_map.mcm_ingress_internal_lb ? "internal" : "external"
  pm4ml_wildcard_gateway    = var.app_var_map.pm4ml_ingress_internal_lb ? "internal" : "external"
  mojaloop_keycloak_realm_env_secret_map = {
    "${var.mcm_oidc_client_secret_secret}" = var.mcm_oidc_client_secret_secret_key
    "${var.jwt_client_secret_secret}"      = var.jwt_client_secret_secret_key
  }
  pm4ml_keycloak_realm_env_secret_map = {
    "${var.pm4ml_oidc_client_secret_secret}" = var.pm4ml_oidc_client_secret_secret_key
    "${var.jwt_client_secret_secret}"        = var.jwt_client_secret_secret_key
  }
  mcm_public_fqdn              = "mcm.${var.public_subdomain}"
  vault_public_fqdn            = "vault.${var.public_subdomain}"
  grafana_public_fqdn          = "grafana.${var.public_subdomain}"
  external_interop_switch_fqdn = "extapi.${var.public_subdomain}"
  internal_interop_switch_fqdn = "intapi.${var.public_subdomain}"
  ttk_frontend_public_fqdn     = "ttkfrontend.${var.public_subdomain}"
  ttk_backend_public_fqdn      = "ttkbackend.${var.public_subdomain}"

  mojaloop_internal_gateway_hosts = concat([local.internal_interop_switch_fqdn],
    local.mojaloop_wildcard_gateway == "internal" ? [local.ttk_frontend_public_fqdn, local.ttk_backend_public_fqdn] : [],
  local.mcm_wildcard_gateway == "internal" ? [local.mcm_public_fqdn] : [])
  mojaloop_external_gateway_hosts = concat(
    local.mojaloop_wildcard_gateway == "external" ? [local.ttk_frontend_public_fqdn, local.ttk_backend_public_fqdn] : [],
  local.mcm_wildcard_gateway == "external" ? [local.mcm_public_fqdn] : [])

  portal_fqdn              = "portal.${var.public_subdomain}"
  experience_api_fqdn      = "experience-api.${var.public_subdomain}"
  mojaloop_connnector_fqdn = "connector.${var.public_subdomain}"

  pm4ml_internal_gateway_hosts = (local.pm4ml_wildcard_gateway == "internal") ? [local.portal_fqdn, local.experience_api_fqdn] : []
  pm4ml_external_gateway_hosts = concat([local.mojaloop_connnector_fqdn],
  local.pm4ml_wildcard_gateway == "external" ? [local.portal_fqdn, local.experience_api_fqdn] : [])

  keycloak_realm_env_secret_map = var.common_var_map.mojaloop_enabled ? local.mojaloop_keycloak_realm_env_secret_map : local.pm4ml_keycloak_realm_env_secret_map

  internal_gateway_hosts = concat([local.keycloak_admin_fqdn],
    local.vault_wildcard_gateway == "internal" ? [local.vault_public_fqdn] : [],
    local.loki_wildcard_gateway == "internal" ? [local.grafana_public_fqdn] : [],
    var.common_var_map.mojaloop_enabled ? local.mojaloop_internal_gateway_hosts : [],
    var.common_var_map.pm4ml_enabled ? local.pm4ml_internal_gateway_hosts : [])
  external_gateway_hosts = concat([local.keycloak_fqdn],
    local.vault_wildcard_gateway == "external" ? [local.vault_public_fqdn] : [],
    local.loki_wildcard_gateway == "external" ? [local.grafana_public_fqdn] : [],
    var.common_var_map.mojaloop_enabled ? local.mojaloop_external_gateway_hosts : [],
    var.common_var_map.pm4ml_enabled ? local.pm4ml_external_gateway_hosts : [])
}
