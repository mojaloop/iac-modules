module "config_deepmerge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.2.0"
  maps    = local.stateful_resources_config_vars_list
}

module "mojaloop" {
  count                                = var.common_var_map.mojaloop_enabled ? 1 : 0
  source                               = "../mojaloop"
  nat_public_ips                       = var.nat_public_ips
  internal_load_balancer_dns           = var.internal_load_balancer_dns
  external_load_balancer_dns           = var.external_load_balancer_dns
  private_subdomain                    = var.private_subdomain
  public_subdomain                     = var.public_subdomain
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
  vault_secret_key                     = var.vault_secret_key
  role_assign_svc_secret               = var.role_assign_svc_secret
  role_assign_svc_user                 = var.role_assign_svc_user
  istio_external_gateway_name          = var.istio_external_gateway_name
  istio_internal_gateway_name          = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
  istio_egress_gateway_namespace       = local.istio_egress_gateway_namespace
  istio_egress_gateway_name            = local.istio_egress_gateway_name
  mojaloop_chart_version               = var.app_var_map.mojaloop_chart_version
  mcm_enabled                          = var.common_var_map.mcm_enabled
  mcm_chart_version                    = var.app_var_map.mcm_chart_version
  mojaloop_enabled                     = var.common_var_map.mojaloop_enabled
  bulk_enabled                         = var.app_var_map.bulk_enabled
  third_party_enabled                  = var.app_var_map.third_party_enabled
  stateful_resources_config_file       = var.mojaloop_stateful_resources_config_file
  local_vault_kv_root_path             = local.local_vault_kv_root_path
  app_var_map                          = var.app_var_map
  auth_fqdn                            = local.auth_fqdn
  ory_namespace                        = var.ory_namespace
  bof_release_name                     = local.bof_release_name
  oathkeeper_auth_provider_name        = local.oathkeeper_auth_provider_name
  keycloak_hubop_realm_name            = var.keycloak_hubop_realm_name
  rbac_api_resources_file              = var.rbac_api_resources_file
  mojaloop_values_override_file        = var.mojaloop_values_override_file
  finance_portal_values_override_file  = var.finance_portal_values_override_file
  fspiop_use_ory_for_auth              = var.app_var_map.fspiop_use_ory_for_auth
  managed_db_host                      = var.managed_db_host
  platform_stateful_res_config         = module.config_deepmerge.merged
}

module "pm4ml" {
  count                                  = var.common_var_map.pm4ml_enabled ? 1 : 0
  source                                 = "../pm4ml"
  nat_public_ips                         = var.nat_public_ips
  internal_load_balancer_dns             = var.internal_load_balancer_dns
  external_load_balancer_dns             = var.external_load_balancer_dns
  private_subdomain                      = var.private_subdomain
  public_subdomain                       = var.public_subdomain
  secrets_key_map                        = var.secrets_key_map
  properties_key_map                     = var.properties_key_map
  output_dir                             = var.output_dir
  gitlab_project_url                     = var.gitlab_project_url
  cluster_name                           = var.cluster_name
  current_gitlab_project_id              = var.current_gitlab_project_id
  gitlab_group_name                      = var.gitlab_group_name
  gitlab_api_url                         = var.gitlab_api_url
  gitlab_server_url                      = var.gitlab_server_url
  kv_path                                = var.kv_path
  cert_manager_service_account_name      = var.cert_manager_service_account_name
  ory_namespace                          = var.ory_namespace
  keycloak_fqdn                          = local.keycloak_fqdn
  keycloak_name                          = var.keycloak_name
  keycloak_namespace                     = var.keycloak_namespace
  vault_namespace                        = var.vault_namespace
  cert_manager_namespace                 = var.cert_manager_namespace
  vault_secret_key                       = var.vault_secret_key
  pm4ml_oidc_client_secret_secret_prefix = var.pm4ml_oidc_client_secret_secret
  pm4ml_oidc_client_id_prefix            = var.pm4ml_oidc_client_id_prefix
  keycloak_pm4ml_realm_name              = var.keycloak_pm4ml_realm_name
  istio_external_gateway_name            = var.istio_external_gateway_name
  istio_internal_gateway_name            = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name   = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name   = local.istio_internal_wildcard_gateway_name
  local_vault_kv_root_path               = local.local_vault_kv_root_path
  auth_fqdn                              = local.auth_fqdn
  oathkeeper_auth_provider_name          = local.oathkeeper_auth_provider_name
  vault_root_ca_name                     = "pki-${var.cluster_name}"
  app_var_map                            = local.pm4ml_var_map
  bof_release_name                       = local.bof_release_name
  role_assign_svc_user                   = var.role_assign_svc_user
  role_assign_svc_secret_prefix          = "role-assign-svc-secret-"
  portal_admin_user                      = var.portal_admin_user
  portal_admin_secret_prefix             = "portal-admin-secret-"
}

module "vnext" {
  count                                = var.common_var_map.vnext_enabled ? 1 : 0
  source                               = "../vnext"
  nat_public_ips                       = var.nat_public_ips
  internal_load_balancer_dns           = var.internal_load_balancer_dns
  external_load_balancer_dns           = var.external_load_balancer_dns
  private_subdomain                    = var.private_subdomain
  public_subdomain                     = var.public_subdomain
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
  vault_secret_key                     = var.vault_secret_key
  role_assign_svc_secret               = var.role_assign_svc_secret
  role_assign_svc_user                 = var.role_assign_svc_user
  istio_external_gateway_name          = var.istio_external_gateway_name
  istio_internal_gateway_name          = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
  istio_egress_gateway_namespace       = local.istio_egress_gateway_namespace
  istio_egress_gateway_name            = local.istio_egress_gateway_name
  vnext_chart_version                  = var.app_var_map.vnext_chart_version
  mcm_enabled                          = var.common_var_map.mcm_enabled
  mcm_chart_version                    = var.app_var_map.mcm_chart_version
  vnext_enabled                        = var.common_var_map.vnext_enabled
  stateful_resources_config_file       = var.vnext_stateful_resources_config_file
  local_vault_kv_root_path             = local.local_vault_kv_root_path
  app_var_map                          = var.app_var_map
  auth_fqdn                            = local.auth_fqdn
  ory_namespace                        = var.ory_namespace
  bof_release_name                     = local.bof_release_name
  oathkeeper_auth_provider_name        = local.oathkeeper_auth_provider_name
  keycloak_hubop_realm_name            = var.keycloak_hubop_realm_name
  rbac_api_resources_file              = var.rbac_api_resources_file
  fspiop_use_ory_for_auth              = var.app_var_map.fspiop_use_ory_for_auth
  managed_db_host                      = var.managed_db_host
  platform_stateful_res_config         = module.config_deepmerge.merged
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

variable "vnext_stateful_resources_config_file" {
  default     = "../config/vnext-stateful-resources.json"
  type        = string
  description = "where to pull stateful resources config for vnext"
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

variable "vault_secret_key" {
  type    = string
  default = "secret"
}
variable "pm4ml_oidc_client_secret_secret" {
  type    = string
  default = "pm4ml-oidc-client-secret"
}

variable "pm4ml_oidc_client_id_prefix" {
  type        = string
  description = "pm4ml_oidc_client_id_prefix"
  default     = "pm4ml-customer-ui"
}

variable "keycloak_pm4ml_realm_name" {
  type        = string
  description = "name of realm for pm4ml api access"
  default     = "pm4mls"
}

variable "role_assign_svc_secret" {
  type    = string
  default = "role-assign-svc-secret"
}
variable "role_assign_svc_user" {
  type    = string
  default = "role-assign-svc"
}

variable "portal_admin_secret" {
  type    = string
  default = "portal-admin-secret"
}
variable "portal_admin_user" {
  type    = string
  default = "portal_admin"
}

variable "rbac_api_resources_file" {
  type = string
}

variable "mojaloop_values_override_file" {
  type = string
}

variable "finance_portal_values_override_file" {
  type = string
}

variable "argocd_ingress_internal_lb" {
  default     = true
  description = "whether argocd should only be available on private network"
}

variable "argocd_namespace" {
  default     = "argocd"
  description = "namespace argocd is deployed to"
}

locals {
  auth_fqdn = "auth.${var.public_subdomain}"

  pm4ml_var_map = {
    for pm4ml in var.app_var_map.pm4mls : pm4ml.pm4ml => pm4ml
  }

  st_res_local_helm_vars        = yamldecode(file("${find_in_parent_folders("default-config/mojaloop-stateful-resources-local-helm.yaml")}"))
  st_res_local_operator_vars    = yamldecode(file("${find_in_parent_folders("default-config/mojaloop-stateful-resources-local-operator.yaml")}"))
  st_res_managed_vars           = yamldecode(file("${find_in_parent_folders("default-config/mojaloop-stateful-resources-managed.yaml")}"))
  
  plt_st_res_vars                      = yamldecode(file("${find_in_parent_folders("${get_env("CONFIG_PATH")}/platform-stateful-resources.yaml")}"))
  stateful_resources_config_vars_list  = [local.st_res_local_helm_vars,local.st_res_local_operator_vars, local.st_res_managed_vars, local.plt_st_res_vars]

}
