module "mojaloop" {
  count                                      = var.common_var_map.mojaloop_enabled ? 1 : 0
  source                                     = "../mojaloop"
  nat_public_ips                             = var.nat_public_ips
  internal_load_balancer_dns                 = var.internal_load_balancer_dns
  external_load_balancer_dns                 = var.external_load_balancer_dns
  private_subdomain                          = var.private_subdomain
  public_subdomain                           = var.public_subdomain
  external_interop_switch_fqdn               = local.external_interop_switch_fqdn
  internal_interop_switch_fqdn               = local.internal_interop_switch_fqdn
  secrets_key_map                            = var.secrets_key_map
  properties_key_map                         = var.properties_key_map
  output_dir                                 = var.output_dir
  gitlab_project_url                         = var.gitlab_project_url
  cluster_name                               = var.cluster_name
  current_gitlab_project_id                  = var.current_gitlab_project_id
  gitlab_group_name                          = var.gitlab_group_name
  gitlab_api_url                             = var.gitlab_api_url
  gitlab_server_url                          = var.gitlab_server_url
  kv_path                                    = var.kv_path
  private_network_cidr                       = var.private_network_cidr
  cert_manager_service_account_name          = var.cert_manager_service_account_name
  nginx_external_namespace                   = var.nginx_external_namespace
  keycloak_fqdn                              = local.keycloak_fqdn
  keycloak_name                              = var.keycloak_name
  keycloak_namespace                         = var.keycloak_namespace
  vault_namespace                            = var.vault_namespace
  cert_manager_namespace                     = var.cert_manager_namespace
  mcm_oidc_client_secret_secret_key          = var.mcm_oidc_client_secret_secret_key
  mcm_oidc_client_secret_secret              = var.mcm_oidc_client_secret_secret
  jwt_client_secret_secret_key               = var.jwt_client_secret_secret_key
  jwt_client_secret_secret                   = var.jwt_client_secret_secret
  vault_secret_key                           = var.vault_secret_key
  role_assign_svc_secret                     = var.role_assign_svc_secret
  role_assign_svc_user                       = var.role_assign_svc_user
  mcm_public_fqdn                            = local.mcm_public_fqdn
  ttk_backend_public_fqdn                    = local.ttk_backend_public_fqdn
  ttk_frontend_public_fqdn                   = local.ttk_frontend_public_fqdn
  istio_external_gateway_name                = var.istio_external_gateway_name
  istio_internal_gateway_name                = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name       = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name       = local.istio_internal_wildcard_gateway_name
  istio_egress_gateway_namespace             = local.istio_egress_gateway_namespace
  istio_egress_gateway_name                  = local.istio_egress_gateway_name
  mojaloop_chart_version                     = var.app_var_map.mojaloop_chart_version
  mcm_enabled                                = var.common_var_map.mcm_enabled
  mcm_chart_version                          = var.app_var_map.mcm_chart_version
  mojaloop_enabled                           = var.common_var_map.mojaloop_enabled
  bulk_enabled                               = var.app_var_map.bulk_enabled
  third_party_enabled                        = var.app_var_map.third_party_enabled
  mojaloop_ingress_internal_lb               = var.app_var_map.mojaloop_ingress_internal_lb
  mcm_ingress_internal_lb                    = var.app_var_map.mcm_ingress_internal_lb
  stateful_resources_config_file             = var.mojaloop_stateful_resources_config_file
  local_vault_kv_root_path                   = local.local_vault_kv_root_path
  app_var_map                                = var.app_var_map
  auth_fqdn                                  = local.auth_fqdn
  ory_namespace                              = var.ory_namespace
  finance_portal_fqdn                        = local.finance_portal_fqdn
  bof_release_name                           = local.bof_release_name
  ory_stack_enabled                          = var.ory_stack_enabled
  oathkeeper_auth_provider_name              = local.oathkeeper_auth_provider_name
  keycloak_hubop_realm_name                  = var.keycloak_hubop_realm_name
  rbac_api_resources_file                    = var.rbac_api_resources_file
}

module "pm4ml" {
  count                                      = var.common_var_map.pm4ml_enabled ? 1 : 0
  source                                     = "../pm4ml"
  nat_public_ips                             = var.nat_public_ips
  internal_load_balancer_dns                 = var.internal_load_balancer_dns
  external_load_balancer_dns                 = var.external_load_balancer_dns
  private_subdomain                          = var.private_subdomain
  public_subdomain                           = var.public_subdomain
  external_interop_switch_fqdn               = local.external_interop_switch_fqdn
  internal_interop_switch_fqdn               = local.internal_interop_switch_fqdn
  secrets_key_map                            = var.secrets_key_map
  properties_key_map                         = var.properties_key_map
  output_dir                                 = var.output_dir
  gitlab_project_url                         = var.gitlab_project_url
  cluster_name                               = var.cluster_name
  current_gitlab_project_id                  = var.current_gitlab_project_id
  gitlab_group_name                          = var.gitlab_group_name
  gitlab_api_url                             = var.gitlab_api_url
  gitlab_server_url                          = var.gitlab_server_url
  kv_path                                    = var.kv_path
  cert_manager_service_account_name          = var.cert_manager_service_account_name
  ory_namespace                              = var.ory_namespace
  keycloak_fqdn                              = local.keycloak_fqdn
  keycloak_name                              = var.keycloak_name
  keycloak_namespace                         = var.keycloak_namespace
  vault_namespace                            = var.vault_namespace
  cert_manager_namespace                     = var.cert_manager_namespace
  vault_secret_key                           = var.vault_secret_key
  pm4ml_oidc_client_secret_secret_prefix     = var.pm4ml_oidc_client_secret_secret
  pm4ml_oidc_client_id_prefix                = var.pm4ml_oidc_client_id_prefix
  keycloak_pm4ml_realm_name                  = var.keycloak_pm4ml_realm_name
  istio_external_gateway_name                = var.istio_external_gateway_name
  istio_internal_gateway_name                = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name       = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name       = local.istio_internal_wildcard_gateway_name
  local_vault_kv_root_path                   = local.local_vault_kv_root_path
  portal_fqdns                               = local.portal_fqdns
  ory_stack_enabled                          = var.ory_stack_enabled
  auth_fqdn                                  = local.auth_fqdn
  oathkeeper_auth_provider_name              = local.oathkeeper_auth_provider_name
  experience_api_fqdns                       = local.experience_api_fqdns
  mojaloop_connnector_fqdns                  = local.mojaloop_connnector_fqdns
  ttk_backend_fqdns                          = local.pm4ml_ttk_backend_fqdns
  ttk_frontend_fqdns                         = local.pm4ml_ttk_frontend_fqdns
  test_fqdns                                 = local.test_fqdns
  vault_root_ca_name                         = "pki-${var.cluster_name}"
  app_var_map                                = local.pm4ml_var_map
  bof_release_name                           = local.bof_release_name
  role_assign_svc_user                       = var.role_assign_svc_user
  role_assign_svc_secret_prefix              = "role-assign-svc-secret-"
  portal_admin_user                          = var.portal_admin_user
  portal_admin_secret_prefix                 = "portal-admin-secret-"
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

locals {
  mojaloop_wildcard_gateway = var.app_var_map.mojaloop_ingress_internal_lb ? "internal" : "external"
  mcm_wildcard_gateway      = var.app_var_map.mcm_ingress_internal_lb ? "internal" : "external"
  pm4ml_var_map = {
    for pm4ml in var.app_var_map.pm4mls : pm4ml.pm4ml => pm4ml
  }
  oidc_providers = var.common_var_map.pm4ml_enabled ? [for pm4ml in var.app_var_map.pm4mls : {
    realm            = "${var.keycloak_pm4ml_realm_name}-${pm4ml.pm4ml}"
    client_id        = "${var.pm4ml_oidc_client_id_prefix}-${pm4ml.pm4ml}"
    secret_name      = "${var.pm4ml_oidc_client_secret_secret}-${pm4ml.pm4ml}"
  }] : []
  mojaloop_keycloak_realm_env_secret_map = {
    "${var.mcm_oidc_client_secret_secret}" = var.mcm_oidc_client_secret_secret_key
    "${var.jwt_client_secret_secret}"      = var.jwt_client_secret_secret_key
  }
  pm4ml_keycloak_realm_env_secret_map = merge(
    {for key, pm4ml in local.pm4ml_var_map : "${var.pm4ml_oidc_client_secret_secret}-${key}" => var.vault_secret_key},
    {for key, pm4ml in local.pm4ml_var_map : "portal-admin-secret-${key}" => var.vault_secret_key},
    {for key, pm4ml in local.pm4ml_var_map : "role-assign-svc-secret-${key}" => var.vault_secret_key}
  )

  pm4ml_wildcard_gateways = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => pm4ml.pm4ml_ingress_internal_lb ? "internal" : "external" }

  mcm_public_fqdn              = "mcm.${var.public_subdomain}"
  auth_fqdn                    = "auth.${var.public_subdomain}"
  vault_public_fqdn            = "vault.${var.public_subdomain}"
  grafana_public_fqdn          = "grafana.${var.public_subdomain}"
  external_interop_switch_fqdn = "extapi.${var.public_subdomain}"
  internal_interop_switch_fqdn = "intapi.${var.public_subdomain}"
  ttk_frontend_public_fqdn     = "ttkfrontend.${var.public_subdomain}"
  ttk_backend_public_fqdn      = "ttkbackend.${var.public_subdomain}"
  finance_portal_fqdn          = "finance-portal.${var.public_subdomain}"

  mojaloop_internal_gateway_hosts = concat([local.internal_interop_switch_fqdn],
    local.mojaloop_wildcard_gateway == "internal" ? [local.ttk_frontend_public_fqdn, local.ttk_backend_public_fqdn] : [],
  local.mcm_wildcard_gateway == "internal" ? [local.mcm_public_fqdn] : [])
  mojaloop_external_gateway_hosts = concat(
    local.mojaloop_wildcard_gateway == "external" ? [local.ttk_frontend_public_fqdn, local.ttk_backend_public_fqdn] : [],
  local.mcm_wildcard_gateway == "external" ? [local.mcm_public_fqdn] : [])

  portal_fqdns              = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "portal-${pm4ml.pm4ml}.${var.public_subdomain}" }
  experience_api_fqdns      = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "exp-${pm4ml.pm4ml}.${var.public_subdomain}" }
  mojaloop_connnector_fqdns = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "conn-${pm4ml.pm4ml}.${var.public_subdomain}" }
  test_fqdns                = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "test-${pm4ml.pm4ml}.${var.public_subdomain}" }
  pm4ml_ttk_frontend_fqdns  = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "ttkfront-${pm4ml.pm4ml}.${var.public_subdomain}" }
  pm4ml_ttk_backend_fqdns   = { for pm4ml in local.pm4ml_var_map : pm4ml.pm4ml => "ttkback-${pm4ml.pm4ml}.${var.public_subdomain}" }

  pm4ml_internal_wildcard_portal_hosts = [for pm4ml in local.pm4ml_var_map : local.portal_fqdns[pm4ml.pm4ml] if local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "internal"]
  pm4ml_external_wildcard_portal_hosts = [for pm4ml in local.pm4ml_var_map : local.portal_fqdns[pm4ml.pm4ml] if local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external"]
  pm4ml_internal_wildcard_exp_hosts    = [for pm4ml in local.pm4ml_var_map : local.experience_api_fqdns[pm4ml.pm4ml] if local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "internal"]
  pm4ml_external_wildcard_exp_hosts    = [for pm4ml in local.pm4ml_var_map : local.experience_api_fqdns[pm4ml.pm4ml] if local.pm4ml_wildcard_gateways[pm4ml.pm4ml] == "external"]

  pm4ml_internal_gateway_hosts = concat(local.pm4ml_internal_wildcard_portal_hosts, local.pm4ml_internal_wildcard_exp_hosts, values(local.pm4ml_ttk_frontend_fqdns), values(local.pm4ml_ttk_backend_fqdns), values(local.test_fqdns))
  pm4ml_external_gateway_hosts = concat(local.pm4ml_external_wildcard_portal_hosts, local.pm4ml_external_wildcard_exp_hosts)

  keycloak_realm_env_secret_map = merge(
    var.common_var_map.mojaloop_enabled ? local.mojaloop_keycloak_realm_env_secret_map : local.pm4ml_keycloak_realm_env_secret_map,
    {
      "${var.hubop_oidc_client_secret_secret}" = var.vault_secret_key
      "${var.role_assign_svc_secret}"          = var.vault_secret_key
      "${var.portal_admin_secret}"             = var.vault_secret_key
    }
  )

  internal_gateway_hosts = concat([local.keycloak_admin_fqdn],
    local.vault_wildcard_gateway == "internal" ? [local.vault_public_fqdn] : [],
    local.grafana_wildcard_gateway == "internal" ? [local.grafana_public_fqdn] : [],
    var.common_var_map.mojaloop_enabled ? local.mojaloop_internal_gateway_hosts : [],
  var.common_var_map.pm4ml_enabled ? local.pm4ml_internal_gateway_hosts : [])
  external_gateway_hosts = concat([local.keycloak_fqdn, local.auth_fqdn, local.finance_portal_fqdn],
    local.vault_wildcard_gateway == "external" ? [local.vault_public_fqdn] : [],
    local.grafana_wildcard_gateway == "external" ? [local.grafana_public_fqdn] : [],
    var.common_var_map.mojaloop_enabled ? local.mojaloop_external_gateway_hosts : [],
  var.common_var_map.pm4ml_enabled ? local.pm4ml_external_gateway_hosts : [])
  bof_managed_portal_fqdns = var.common_var_map.mojaloop_enabled ? [local.finance_portal_fqdn, local.mcm_public_fqdn] : concat(local.pm4ml_external_wildcard_portal_hosts, local.pm4ml_internal_wildcard_portal_hosts)
}
