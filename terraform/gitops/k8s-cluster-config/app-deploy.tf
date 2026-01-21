module "config_deepmerge" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "0.2.0"
  maps    = local.stateful_resources_config_vars_list
}

module "mojaloop" {
  count                                        = var.common_var_map.mojaloop_enabled ? 1 : 0
  source                                       = "../mojaloop"
  nat_public_ips                               = var.nat_public_ips
  internal_load_balancer_dns                   = var.internal_load_balancer_dns
  external_load_balancer_dns                   = var.external_load_balancer_dns
  private_subdomain                            = var.private_subdomain
  public_subdomain                             = var.public_subdomain
  secrets_key_map                              = var.secrets_key_map
  properties_key_map                           = var.properties_key_map
  output_dir                                   = var.output_dir
  gitlab_project_url                           = var.gitlab_project_url
  cluster_name                                 = var.cluster_name
  current_gitlab_project_id                    = var.current_gitlab_project_id
  gitlab_group_name                            = var.gitlab_group_name
  gitlab_api_url                               = var.gitlab_api_url
  gitlab_server_url                            = var.gitlab_server_url
  kv_path                                      = var.kv_path
  private_network_cidr                         = var.private_network_cidr
  cert_manager_service_account_name            = var.cert_manager_service_account_name
  nginx_external_namespace                     = var.nginx_external_namespace
  keycloak_fqdn                                = local.keycloak_fqdn
  keycloak_name                                = var.keycloak_name
  keycloak_namespace                           = var.keycloak_namespace
  vault_namespace                              = var.vault_namespace
  cert_manager_namespace                       = var.cert_manager_namespace
  vault_secret_key                             = var.vault_secret_key
  role_assign_svc_secret                       = var.role_assign_svc_secret
  role_assign_svc_user                         = var.role_assign_svc_user
  istio_external_gateway_name                  = var.istio_external_gateway_name
  istio_internal_gateway_name                  = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name         = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name         = local.istio_internal_wildcard_gateway_name
  mcm_enabled                                  = var.common_var_map.mcm_enabled
  mcm_chart_version                            = var.app_var_map.mcm_chart_version
  mojaloop_enabled                             = var.common_var_map.mojaloop_enabled
  bulk_enabled                                 = var.app_var_map.bulk_enabled
  third_party_enabled                          = var.app_var_map.third_party_enabled
  ttk_dev_mode_enabled                         = var.app_var_map.ttk_dev_mode_enabled
  local_vault_kv_root_path                     = local.local_vault_kv_root_path
  opentelemetry_enabled                        = var.common_var_map.opentelemetry_enabled
  opentelemetry_namespace_filtering_enable     = var.common_var_map.opentelemetry_namespace_filtering_enable
  app_var_map                                  = var.app_var_map
  auth_fqdn                                    = local.auth_fqdn
  ory_namespace                                = var.ory_namespace
  bof_release_name                             = local.bof_release_name
  oathkeeper_auth_provider_name                = local.oathkeeper_auth_provider_name
  vault_root_ca_name                           = "pki-${var.cluster_name}"
  keycloak_hubop_realm_name                    = var.keycloak_hubop_realm_name
  mcm_admin_client_secret_name         = var.mcm_admin_client_secret_name
  mcm_oidc_client_secret_secret        = var.mcm_oidc_client_secret_secret
  mcm_oidc_client_secret_secret_key    = var.mcm_oidc_client_secret_secret_key
  hubop_oidc_client_id                 = var.hubop_oidc_client_id
  hubop_oidc_client_secret_secret      = var.hubop_oidc_client_secret_secret
  smtp_from                            = var.app_var_map.smtp_from
  smtp_from_display_name               = var.app_var_map.smtp_from_display_name
  smtp_reply_to                        = var.app_var_map.smtp_reply_to
  smtp_host                            = var.app_var_map.smtp_host
  smtp_port                            = var.app_var_map.smtp_port
  smtp_ssl                             = var.app_var_map.smtp_ssl
  smtp_starttls                        = var.app_var_map.smtp_starttls
  smtp_auth                            = var.app_var_map.smtp_auth
  rbac_api_resources_file                      = var.rbac_api_resources_file
  mojaloop_values_override_file                = var.mojaloop_values_override_file
  mcm_values_override_file                     = var.mcm_values_override_file
  finance_portal_values_override_file          = var.finance_portal_values_override_file
  values_hub_provisioning_override_file        = var.values_hub_provisioning_override_file
  values_reporting_k8s_templates_override_file = var.values_reporting_k8s_templates_override_file
  fspiop_use_ory_for_auth                      = var.app_var_map.fspiop_use_ory_for_auth
  platform_stateful_res_config                 = module.config_deepmerge.merged
  object_store_api_url                         = var.object_store_api_url
  object_store_region                          = var.object_store_region
  object_store_percona_backup_bucket           = data.gitlab_project_variable.object_store_percona_backup_bucket.value
  external_secret_sync_wave                    = var.external_secret_sync_wave
  pm4mls                                       = merge(local.pm4ml_var_map, local.proxy_pm4ml_var_map)
  monolith_stateful_resources                  = local.monolith_stateful_resources
  ml_testing_toolkit_cli_chart_version         = var.app_var_map.ml_testing_toolkit_cli_chart_version
  hub_provisioning_ttk_test_case_version       = var.app_var_map.hub_provisioning_ttk_test_case_version
  managed_svc_as_monolith                      = var.deploy_env_monolithic_db
  deploy_env_monolithic_db                     = var.deploy_env_monolithic_db
  storage_class_name                           = var.storage_class_name
  cloud_platform                               = var.cloud_platform
  cc_name                                      = var.cc_name
  vpc_cidr                                     = var.vpc_cidr
  vpc_id                                       = var.vpc_id
  database_subnets                             = var.database_subnets
  availability_zones                           = var.availability_zones
  cloud_region                                 = var.cloud_region
  private_dns_zone_id                          = var.private_dns_zone_id
  istio_nb_egress_waypoint_name                = var.istio_nb_egress_waypoint_name
  istio_nb_egress_waypoint_namespace           = var.istio_nb_egress_waypoint_namespace
  traces_endpoint                              = var.traces_endpoint
  namespace_meta                               = local.namespace_meta
  mojaloop_charts_repo                         = local.mojaloop_charts_repo
  mcm_chart_repo                               = local.mcm_chart_repo
  mojaloop_helm_repo                           = local.mojaloop_helm_repo
  reporting_templates_chart_repo               = local.mojaloop_reporting_templates_repo
  mojaloop_helm_version                        = var.app_var_map.mojaloop_helm_version
  helm_proxy_repos_map                         = local.helm_proxy_repos_map
}

module "pm4ml" {
  count                                    = var.common_var_map.pm4ml_enabled ? 1 : 0
  source                                   = "../pm4ml"
  nat_public_ips                           = var.nat_public_ips
  internal_load_balancer_dns               = var.internal_load_balancer_dns
  external_load_balancer_dns               = var.external_load_balancer_dns
  private_subdomain                        = var.private_subdomain
  public_subdomain                         = var.public_subdomain
  secrets_key_map                          = var.secrets_key_map
  properties_key_map                       = var.properties_key_map
  output_dir                               = var.output_dir
  gitlab_project_url                       = var.gitlab_project_url
  cluster_name                             = var.cluster_name
  current_gitlab_project_id                = var.current_gitlab_project_id
  gitlab_group_name                        = var.gitlab_group_name
  gitlab_api_url                           = var.gitlab_api_url
  gitlab_server_url                        = var.gitlab_server_url
  kv_path                                  = var.kv_path
  cert_manager_service_account_name        = var.cert_manager_service_account_name
  ory_namespace                            = var.ory_namespace
  keycloak_fqdn                            = local.keycloak_fqdn
  keycloak_name                            = var.keycloak_name
  keycloak_namespace                       = var.keycloak_namespace
  vault_namespace                          = var.vault_namespace
  cert_manager_namespace                   = var.cert_manager_namespace
  vault_secret_key                         = var.vault_secret_key
  pm4ml_oidc_client_secret_secret_prefix   = var.pm4ml_oidc_client_secret_secret
  pm4ml_oidc_client_id_prefix              = var.pm4ml_oidc_client_id_prefix
  keycloak_pm4ml_realm_name                = var.keycloak_pm4ml_realm_name
  istio_external_gateway_name              = var.istio_external_gateway_name
  istio_internal_gateway_name              = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name     = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name     = local.istio_internal_wildcard_gateway_name
  local_vault_kv_root_path                 = local.local_vault_kv_root_path
  auth_fqdn                                = local.auth_fqdn
  oathkeeper_auth_provider_name            = local.oathkeeper_auth_provider_name
  vault_root_ca_name                       = "pki-${var.cluster_name}"
  app_var_map                              = local.pm4ml_var_map
  root_var_map                             = var.app_var_map
  cluster                                  = local.cluster
  bof_release_name                         = local.bof_release_name
  role_assign_svc_user                     = var.role_assign_svc_user
  role_assign_svc_secret_prefix            = "role-assign-svc-secret-"
  portal_admin_user                        = var.portal_admin_user
  portal_admin_secret_prefix               = "portal-admin-secret-"
  mcm_admin_user                           = var.mcm_admin_user
  mcm_admin_secret_prefix                  = "mcm-admin-secret-"
  pm4ml_values_override_file               = var.pm4ml_values_override_file
  admin_portal_values_override_file        = var.admin_portal_values_override_file
  opentelemetry_enabled                    = var.common_var_map.opentelemetry_enabled
  opentelemetry_namespace_filtering_enable = var.common_var_map.opentelemetry_namespace_filtering_enable
  storage_class_name                       = var.storage_class_name
  cloud_platform                           = var.cloud_platform
  private_dns_zone_id                      = var.private_dns_zone_id
  traces_endpoint                          = var.traces_endpoint
  pm4ml_chart_repo                         = local.pm4ml_chart_repo
  mojaloop_charts_repo                     = local.mojaloop_charts_repo
}

module "proxy_pm4ml" {
  count                                    = var.common_var_map.proxy_pm4ml_enabled ? 1 : 0
  source                                   = "../proxy-pm4ml"
  nat_public_ips                           = var.nat_public_ips
  internal_load_balancer_dns               = var.internal_load_balancer_dns
  external_load_balancer_dns               = var.external_load_balancer_dns
  private_subdomain                        = var.private_subdomain
  public_subdomain                         = var.public_subdomain
  secrets_key_map                          = var.secrets_key_map
  properties_key_map                       = var.properties_key_map
  output_dir                               = var.output_dir
  gitlab_project_url                       = var.gitlab_project_url
  cluster_name                             = var.cluster_name
  current_gitlab_project_id                = var.current_gitlab_project_id
  gitlab_group_name                        = var.gitlab_group_name
  gitlab_api_url                           = var.gitlab_api_url
  gitlab_server_url                        = var.gitlab_server_url
  kv_path                                  = var.kv_path
  cert_manager_service_account_name        = var.cert_manager_service_account_name
  vault_namespace                          = var.vault_namespace
  cert_manager_namespace                   = var.cert_manager_namespace
  istio_external_gateway_name              = var.istio_external_gateway_name
  istio_internal_gateway_name              = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name     = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name     = local.istio_internal_wildcard_gateway_name
  local_vault_kv_root_path                 = local.local_vault_kv_root_path
  vault_root_ca_name                       = "pki-${var.cluster_name}"
  app_var_map                              = local.proxy_pm4ml_var_map
  proxy_values_override_file               = var.proxy_values_override_file
  opentelemetry_enabled                    = var.common_var_map.opentelemetry_enabled
  opentelemetry_namespace_filtering_enable = var.common_var_map.opentelemetry_namespace_filtering_enable
  storage_class_name                       = var.storage_class_name
  cloud_platform                           = var.cloud_platform
  private_dns_zone_id                      = var.private_dns_zone_id
  traces_endpoint                          = var.traces_endpoint
  proxy_pm4ml_chart_repo                   = local.pm4ml_chart_repo
  mojaloop_charts_repo                     = local.mojaloop_charts_repo
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
  hubop_oidc_client_secret_secret      = var.hubop_oidc_client_secret_secret
  vault_secret_key                     = var.vault_secret_key
  role_assign_svc_secret               = var.role_assign_svc_secret
  role_assign_svc_user                 = var.role_assign_svc_user
  istio_external_gateway_name          = var.istio_external_gateway_name
  istio_internal_gateway_name          = var.istio_internal_gateway_name
  istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
  istio_internal_wildcard_gateway_name = local.istio_internal_wildcard_gateway_name
  vnext_chart_version                  = var.app_var_map.vnext_chart_version
  mcm_enabled                          = var.common_var_map.mcm_enabled
  mcm_chart_version                    = var.app_var_map.mcm_chart_version
  vnext_enabled                        = var.common_var_map.vnext_enabled
  bulk_enabled                         = var.app_var_map.bulk_enabled
  local_vault_kv_root_path             = local.local_vault_kv_root_path
  app_var_map                          = var.app_var_map
  auth_fqdn                            = local.auth_fqdn
  ory_namespace                        = var.ory_namespace
  bof_release_name                     = local.bof_release_name
  oathkeeper_auth_provider_name        = local.oathkeeper_auth_provider_name
  keycloak_hubop_realm_name            = var.keycloak_hubop_realm_name
  mcm_admin_client_secret_name         = var.mcm_admin_client_secret_name
  mcm_oidc_client_secret_secret        = var.mcm_oidc_client_secret_secret
  mcm_oidc_client_secret_secret_key    = var.mcm_oidc_client_secret_secret_key
  smtp_from                            = var.app_var_map.smtp_from
  smtp_from_display_name               = var.app_var_map.smtp_from_display_name
  smtp_reply_to                        = var.app_var_map.smtp_reply_to
  smtp_host                            = var.app_var_map.smtp_host
  smtp_port                            = var.app_var_map.smtp_port
  smtp_ssl                             = var.app_var_map.smtp_ssl
  smtp_starttls                        = var.app_var_map.smtp_starttls
  smtp_auth                            = var.app_var_map.smtp_auth
  rbac_api_resources_file              = var.rbac_api_resources_file
  fspiop_use_ory_for_auth              = var.app_var_map.fspiop_use_ory_for_auth
  platform_stateful_res_config         = module.config_deepmerge.merged
  object_store_api_url                 = var.object_store_api_url
  object_store_region                  = var.object_store_region
  object_store_percona_backup_bucket   = data.gitlab_project_variable.object_store_percona_backup_bucket.value
  external_secret_sync_wave            = var.external_secret_sync_wave
  monolith_stateful_resources          = local.monolith_stateful_resources
  managed_svc_as_monolith              = var.deploy_env_monolithic_db
  deploy_env_monolithic_db             = var.deploy_env_monolithic_db
  storage_class_name                   = var.storage_class_name
  cloud_platform                       = var.cloud_platform
  cc_name                              = var.cc_name
  vpc_cidr                             = var.vpc_cidr
  vpc_id                               = var.vpc_id
  database_subnets                     = var.database_subnets
  availability_zones                   = var.availability_zones
  cloud_region                         = var.cloud_region
  private_dns_zone_id                  = var.private_dns_zone_id
  istio_nb_egress_waypoint_name        = var.istio_nb_egress_waypoint_name
  istio_nb_egress_waypoint_namespace   = var.istio_nb_egress_waypoint_namespace
  helm_proxy_repos_map                 = local.helm_proxy_repos_map
}

variable "app_var_map" {
  type = any
}
variable "common_var_map" {
  type = any
}

variable "mojaloop_stateful_res_helm_config_file" {
  default     = "../config/mojaloop-stateful-resources-local-helm.yaml"
  type        = string
  description = "where to pull stateful resources config for mojaloop"
}

variable "mojaloop_stateful_res_op_config_file" {
  default     = "../config/mojaloop-stateful-resources-local-operator.yaml"
  type        = string
  description = "where to pull stateful resources config for mojaloop"
}

# variable "mojaloop_stateful_res_mangd_config_file" {
#   default     = "../config/mojaloop-stateful-resources-managed.yaml"
#   type        = string
#   description = "where to pull stateful resources config for mojaloop"
# }

variable "mojaloop_stateful_res_monolith_config_file" {
  default     = "../config/mojaloop-stateful-resources-monolith-databases.yaml"
  type        = string
  description = "where to pull monolith stateful resources config for mojaloop"
}

variable "platform_stateful_resources_config_file" {
  default     = "../config/platform-stateful-resources.yaml"
  type        = string
  description = "where to pull stateful resources config for mojaloop"
}

variable "private_network_cidr" {
  description = "network cidr for private network"
  type        = string
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

variable "mcm_admin_secret" {
  type    = string
  default = "mcm-admin-secret"
}

variable "mcm_admin_user" {
  type    = string
  default = "mcm_admin"
}

variable "mcm_admin_client_secret_name" {
  type        = string
  description = "name of MCM admin client secret for Keycloak administrative operations"
  default     = "mcm-admin-client-secret"
}

variable "mcm_oidc_client_secret_secret" {
  type        = string
  description = "MCM OIDC client secret name in Vault"
  default     = "mcm-oidc-client-secret"
}

variable "mcm_oidc_client_secret_secret_key" {
  type        = string
  description = "MCM OIDC client secret key in Vault"
  default     = "secret"
}

variable "rbac_api_resources_file" {
  type = string
}

variable "mojaloop_values_override_file" {
  type = string
}

variable "mcm_values_override_file" {
  type = string
}

variable "proxy_values_override_file" {
  type = string
}

variable "pm4ml_values_override_file" {
  type = string
}

variable "admin_portal_values_override_file" {
  type = string
}

variable "finance_portal_values_override_file" {
  type = string
}

variable "values_hub_provisioning_override_file" {
  type = string
}

variable "values_reporting_k8s_templates_override_file" {
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

variable "object_store_region" {
  type        = string
  description = "object_store_region"
}
locals {
  auth_fqdn = "auth.${var.private_subdomain}"

  pm4ml_var_map       = try(var.app_var_map.pm4mls, {})
  proxy_pm4ml_var_map = try(var.app_var_map.proxy_pm4mls, {})
  cluster             = var.app_var_map.cluster

  st_res_local_helm_vars     = yamldecode(templatefile(var.mojaloop_stateful_res_helm_config_file, local.cluster))
  st_res_local_operator_vars = yamldecode(templatefile(var.mojaloop_stateful_res_op_config_file, local.cluster))
  #st_res_managed_vars           = yamldecode(templatefile(var.mojaloop_stateful_res_mangd_config_file, local.cluster))
  plt_st_res_config               = yamldecode(templatefile(var.platform_stateful_resources_config_file, local.cluster))
  monolith_stateful_resources_int = yamldecode(templatefile(var.mojaloop_stateful_res_monolith_config_file, local.cluster))

  monolith_stateful_resources = { for key, resource in local.monolith_stateful_resources_int : key => resource if var.deploy_env_monolithic_db }

  stateful_resources_config_vars_list = [local.st_res_local_helm_vars, local.st_res_local_operator_vars, local.plt_st_res_config]
  namespace_meta                      = var.namespace_meta_config_file == "" ? {} : yamldecode(file(var.namespace_meta_config_file))
  pm4ml_chart_repo                    = startswith(var.pm4ml_chart_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.pm4ml_chart_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.pm4ml_chart_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.pm4ml_chart_repo)[1]}", var.pm4ml_chart_repo) : try(local.helm_proxy_repos_map[var.pm4ml_chart_repo], var.pm4ml_chart_repo)
  mojaloop_charts_repo                = startswith(var.mojaloop_charts_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.mojaloop_charts_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.mojaloop_charts_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.mojaloop_charts_repo)[1]}", var.mojaloop_charts_repo) : try(local.helm_proxy_repos_map[var.mojaloop_charts_repo], var.mojaloop_charts_repo)
  mcm_chart_repo                      = startswith(var.mcm_chart_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.mcm_chart_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.mcm_chart_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.mcm_chart_repo)[1]}", var.mcm_chart_repo) : try(local.helm_proxy_repos_map[var.mcm_chart_repo], var.mcm_chart_repo)
  mojaloop_helm_repo                  = startswith(var.mojaloop_helm_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.mojaloop_helm_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.mojaloop_helm_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.mojaloop_helm_repo)[1]}", var.mojaloop_helm_repo) : try(local.helm_proxy_repos_map[var.mojaloop_helm_repo], var.mojaloop_helm_repo)
  mojaloop_reporting_templates_repo   = startswith(var.mojaloop_reporting_templates_repo, "oci://") && can(regex("(oci://[^/]+)(.*)", var.mojaloop_reporting_templates_repo)) ? try("${local.helm_proxy_repos_map[regex("(oci://[^/]+)(.*)", var.mojaloop_reporting_templates_repo)[0]]}${regex("(oci://[^/]+)(.*)", var.mojaloop_reporting_templates_repo)[1]}", var.mojaloop_reporting_templates_repo) : try(local.helm_proxy_repos_map[var.mojaloop_reporting_templates_repo], var.mojaloop_reporting_templates_repo)
}
