module "generate_keycloak_files" {
  source = "../generate-files"
  var_map = {
    keycloak_name                         = var.keycloak_name
    keycloak_operator_version             = var.common_var_map.keycloak_operator_version
    keycloak_namespace                    = var.keycloak_namespace
    gitlab_project_url                    = var.gitlab_project_url
    keycloak_mysql_database            = try(module.common_stateful_resources.stateful_resources[local.keycloak_mysql_resource_index].logical_service_config.database_name,"")
    keycloak_mysql_user                = try(module.common_stateful_resources.stateful_resources[local.keycloak_mysql_resource_index].logical_service_config.db_username,"")
    keycloak_mysql_host                = "${try(module.common_stateful_resources.stateful_resources[local.keycloak_mysql_resource_index].logical_service_config.logical_service_name,"")}.${var.stateful_resources_namespace}.svc.cluster.local"
    keycloak_mysql_password_secret     = try(module.common_stateful_resources.stateful_resources[local.keycloak_mysql_resource_index].logical_service_config.user_password_secret,"")
    keycloak_mysql_port                = try(module.common_stateful_resources.stateful_resources[local.keycloak_mysql_resource_index].logical_service_config.logical_service_port,"")
    keycloak_mysql_password_secret_key = "mysql-password"
    keycloak_fqdn                              = local.keycloak_fqdn
    keycloak_istio_wildcard_gateway_name       = local.keycloak_istio_wildcard_gateway_name
    keycloak_istio_gateway_name                = local.keycloak_istio_gateway_name
    keycloak_istio_gateway_namespace           = local.keycloak_istio_gateway_namespace
    keycloak_admin_fqdn                        = local.keycloak_admin_fqdn
    keycloak_admin_istio_gateway_namespace     = local.keycloak_admin_istio_gateway_namespace
    keycloak_admin_istio_wildcard_gateway_name = local.keycloak_admin_istio_wildcard_gateway_name
    keycloak_dfsp_realm_name                   = var.keycloak_dfsp_realm_name
    keycloak_sync_wave                         = var.keycloak_sync_wave
    keycloak_post_config_sync_wave             = var.keycloak_post_config_sync_wave
    ingress_class                              = var.keycloak_ingress_internal_lb ? var.internal_ingress_class_name : var.external_ingress_class_name
    #istio_internal_wildcard_gateway_name  = local.istio_internal_wildcard_gateway_name
    #istio_internal_gateway_namespace      = var.istio_internal_gateway_namespace
    #istio_external_wildcard_gateway_name  = local.istio_external_wildcard_gateway_name
    #istio_external_gateway_namespace      = var.istio_external_gateway_namespace
    #istio_external_gateway_name           = var.istio_external_gateway_name
    #keycloak_wildcard_gateway             = local.keycloak_wildcard_gateway
    external_ingress_class_name   = var.external_ingress_class_name
    keycloak_tls_secretname       = var.default_ssl_certificate
    istio_create_ingress_gateways = var.istio_create_ingress_gateways
    ref_secrets                   = local.keycloak_realm_env_secret_map
    ref_secrets_path              = local.keycloak_secrets_path
  }
  file_list       = [for f in fileset(local.keycloak_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.keycloak_app_file, f))]
  template_path   = local.keycloak_template_path
  output_path     = "${var.output_dir}/keycloak"
  app_file        = local.keycloak_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  keycloak_template_path = "${path.module}/../generate-files/templates/keycloak"
  keycloak_app_file      = "keycloak-app.yaml"
}

variable "keycloak_ingress_internal_lb" {
  type        = bool
  description = "keycloak_ingress_internal_lb"
  default     = false
}

variable "keycloak_admin_ingress_internal_lb" {
  type        = bool
  description = "keycloak_admin_ingress_internal_lb"
  default     = true
}

variable "keycloak_name" {
  default     = "switch-keycloak"
  type        = string
  description = "name of keycloak instance"
}

variable "keycloak_sync_wave" {
  type        = string
  description = "keycloak_sync_wave"
  default     = "-4"
}

variable "keycloak_post_config_sync_wave" {
  type        = string
  description = "keycloak_post_config_sync_wave"
  default     = "-3"
}

variable "keycloak_namespace" {
  type        = string
  description = "keycloak_namespace"
  default     = "keycloak"
}
# rm this later, this is for nginx backwards compatability, not used in istio
variable "keycloak_dfsp_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "dfsps"
}

locals {
  keycloak_mysql_resource_index           = "keycloak-db"
  keycloak_wildcard_gateway                  = var.keycloak_ingress_internal_lb ? "internal" : "external"
  keycloak_admin_wildcard_gateway            = var.keycloak_admin_ingress_internal_lb ? "internal" : "external"
  keycloak_fqdn                              = local.keycloak_wildcard_gateway == "external" ? "keycloak.${var.public_subdomain}" : "keycloak.${var.private_subdomain}"
  keycloak_istio_wildcard_gateway_name       = local.keycloak_wildcard_gateway == "external" ? local.istio_external_wildcard_gateway_name : local.istio_internal_wildcard_gateway_name
  keycloak_istio_gateway_namespace           = local.keycloak_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  keycloak_admin_fqdn                        = local.keycloak_admin_wildcard_gateway == "external" ? "admin-keycloak.${var.public_subdomain}" : "admin-keycloak.${var.private_subdomain}"
  keycloak_admin_istio_wildcard_gateway_name = local.keycloak_admin_wildcard_gateway == "external" ? local.istio_external_wildcard_gateway_name : local.istio_internal_wildcard_gateway_name
  keycloak_admin_istio_gateway_namespace     = local.keycloak_admin_wildcard_gateway == "external" ? var.istio_external_gateway_namespace : var.istio_internal_gateway_namespace
  keycloak_istio_gateway_name                = local.keycloak_wildcard_gateway == "external" ? var.istio_external_gateway_name : var.istio_internal_gateway_name
  keycloak_secrets_path                      = "/secret/keycloak"

  mojaloop_keycloak_realm_env_secret_map = {
    "${var.mcm_oidc_client_secret_secret}" = var.mcm_oidc_client_secret_secret_key
    "${var.jwt_client_secret_secret}"      = var.jwt_client_secret_secret_key
  }
  
  pm4ml_keycloak_realm_env_secret_map = merge(
    { for key, pm4ml in local.pm4ml_var_map : "${var.pm4ml_oidc_client_secret_secret}-${key}" => var.vault_secret_key },
    { for key, pm4ml in local.pm4ml_var_map : "portal-admin-secret-${key}" => var.vault_secret_key },
    { for key, pm4ml in local.pm4ml_var_map : "role-assign-svc-secret-${key}" => var.vault_secret_key }
  )

  keycloak_realm_env_secret_map = merge(
    (var.common_var_map.mojaloop_enabled || var.common_var_map.vnext_enabled) ? local.mojaloop_keycloak_realm_env_secret_map : local.pm4ml_keycloak_realm_env_secret_map,
    {
      "${var.hubop_oidc_client_secret_secret}" = var.vault_secret_key
      "${var.role_assign_svc_secret}"          = var.vault_secret_key
      "${var.portal_admin_secret}"             = var.vault_secret_key
    }
  )
}
