module "generate_ory_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                   = var.gitlab_project_url
    ory_sync_wave                        = var.ory_sync_wave
    oathkeeper_chart_version             = try(var.common_var_map.oathkeeper_chart_version, var.oathkeeper_chart_version)
    kratos_chart_version                 = try(var.common_var_map.kratos_chart_version, var.kratos_chart_version)
    keto_chart_version                   = try(var.common_var_map.keto_chart_version, var.keto_chart_version)
    self_service_ui_chart_version        = try(var.common_var_map.self_service_ui_chart_version, var.self_service_ui_chart_version)
    ory_namespace                        = var.ory_namespace
    auth_fqdn                            = local.auth_fqdn
    public_subdomain                     = var.public_subdomain
    private_subdomain                    = var.private_subdomain
    keto_mysql_database               = try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].logical_service_config.database_name,"")
    keto_mysql_user                   = try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].logical_service_config.db_username,"")
    keto_mysql_host                   = "${try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].logical_service_config.logical_service_name,"")}.${var.stateful_resources_namespace}.svc.cluster.local"
    keto_mysql_password_secret        = try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].logical_service_config.user_password_secret,"")
    keto_mysql_port                   = try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].logical_service_config.logical_service_port,"")
    keto_mysql_secret_path            = "${try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].local_helm_config.secret_config.generate_secret_vault_base_path,"")}/${local.keto_mysql_resource_index}/${try(module.common_stateful_resources.stateful_resources[local.keto_mysql_resource_index].local_helm_config.secret_config.generate_secret_name,"")}-mysql-password"
    keto_mysql_password_secret_key    = "password"
    kratos_mysql_database             = try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].logical_service_config.database_name,"")
    kratos_mysql_user                 = try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].logical_service_config.db_username,"")
    kratos_mysql_host                 = "${try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].logical_service_config.logical_service_name,"")}.${var.stateful_resources_namespace}.svc.cluster.local"
    kratos_mysql_password_secret      = try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].logical_service_config.user_password_secret,"")
    kratos_mysql_port                 = try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].logical_service_config.logical_service_port,"")
    kratos_mysql_secret_path          = "${try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].local_helm_config.secret_config.generate_secret_vault_base_path,"")}/${local.kratos_mysql_resource_index}/${try(module.common_stateful_resources.stateful_resources[local.kratos_mysql_resource_index].local_helm_config.secret_config.generate_secret_name,"")}-mysql-password"
    kratos_mysql_password_secret_key  = "password"
    hubop_oidc_client_secret_secret_name = join("$", ["", "{${replace(var.hubop_oidc_client_secret_secret, "-", "_")}}"])
    hubop_oidc_client_secret_secret      = var.hubop_oidc_client_secret_secret
    hubop_oidc_client_id                 = var.hubop_oidc_client_id
    hubop_oidc_client_secret_secret_path = local.keycloak_secrets_path
    keycloak_hubop_realm_name            = var.keycloak_hubop_realm_name
    keycloak_name                        = var.keycloak_name
    keycloak_fqdn                        = local.keycloak_fqdn
    istio_external_gateway_namespace     = var.istio_external_gateway_namespace
    keycloak_namespace                   = var.keycloak_namespace
    istio_external_wildcard_gateway_name = local.istio_external_wildcard_gateway_name
    bof_chart_version                    = try(var.app_var_map.bof_chart_version, var.bof_chart_version)
    bof_release_name                     = local.bof_release_name
    vault_secret_key                     = var.vault_secret_key
    role_assign_svc_secret_name          = join("$", ["", "{${replace(var.role_assign_svc_secret, "-", "_")}}"])
    role_assign_svc_user                 = var.role_assign_svc_user
    portal_admin_secret_name             = join("$", ["", "{${replace(var.portal_admin_secret, "-", "_")}}"])
    portal_admin_user                    = var.portal_admin_user
    mcm_admin_secret_name                = join("$", ["", "{${replace(var.mcm_admin_secret, "-", "_")}}"])
    mcm_admin_user                       = var.mcm_admin_user
    oidc_providers                       = local.oidc_providers
    permissionExclusions                 = local.permissionExclusions
    mojaloopRoles                        = local.mojaloopRoles
  }
  file_list       = [for f in fileset(local.ory_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.ory_app_file, f))]
  template_path   = local.ory_template_path
  output_path     = "${var.output_dir}/ory"
  app_file        = local.ory_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "ory_sync_wave" {
  type        = string
  description = "ory_sync_wave"
  default     = "-3"
}
variable "oathkeeper_chart_version" {
  type        = string
  description = "oathkeeper_chart_version"
  default     = "0.39.0"
}
variable "kratos_chart_version" {
  type        = string
  description = "kratos_chart_version"
  default     = "0.39.0"
}
variable "keto_chart_version" {
  type        = string
  description = "keto_chart_version"
  default     = "0.39.0"
}
variable "self_service_ui_chart_version" {
  type        = string
  description = "self_service_ui_chart_version"
  default     = "0.39.0"
}
variable "ory_namespace" {
  type        = string
  description = "ory_namespace"
  default     = "ory"
}

variable "hubop_oidc_client_secret_secret" {
  type        = string
  description = "hubop_oidc_client_secret_secret"
  default     = "hubop-oidc-secret"
}

variable "hubop_oidc_client_id" {
  type        = string
  description = "hubop_oidc_client_id"
  default     = "hub-op"
}

variable "keycloak_hubop_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "hub-operators"
}
variable "bof_chart_version" {
  type    = string
  default = "5.1.0"
}

variable "rbac_permissions_file" {
  type = string
}
locals {
  ory_template_path              = "${path.module}/../generate-files/templates/ory"
  ory_app_file                   = "ory-app.yaml"
  kratos_mysql_resource_index = "kratos-db"
  keto_mysql_resource_index   = "keto-db"
  oathkeeper_auth_url            = "oathkeeper-api.${var.ory_namespace}.svc.cluster.local"
  oathkeeper_auth_provider_name  = "ory-authz"
  bof_release_name               = "bof"
  rolesPermissions               = yamldecode(file(var.rbac_permissions_file))
  mojaloopRoles                  = local.rolesPermissions["roles"]
  permissionExclusions           = local.rolesPermissions["permission-exclusions"]

  oidc_providers = var.common_var_map.pm4ml_enabled ? [for pm4ml, _ in var.app_var_map.pm4mls : {
    realm       = "${var.keycloak_pm4ml_realm_name}-${pm4ml}"
    client_id   = "${var.pm4ml_oidc_client_id_prefix}-${pm4ml}"
    secret_name = "${var.pm4ml_oidc_client_secret_secret}-${pm4ml}"
  }] : []
}
