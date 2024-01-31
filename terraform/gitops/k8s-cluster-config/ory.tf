module "generate_ory_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                    = var.gitlab_project_url
    ory_sync_wave                         = var.ory_sync_wave
    ory_stack_enabled                     = try(var.common_var_map.ory_stack_enabled, var.ory_stack_enabled)
    oathkeeper_chart_version              = try(var.common_var_map.oathkeeper_chart_version, var.oathkeeper_chart_version)
    kratos_chart_version                  = try(var.common_var_map.kratos_chart_version, var.kratos_chart_version)
    keto_chart_version                    = try(var.common_var_map.keto_chart_version, var.keto_chart_version)
    self_service_ui_chart_version         = try(var.common_var_map.self_service_ui_chart_version, var.self_service_ui_chart_version)
    bof_chart_version                     = try(var.common_var_map.bof_chart_version, var.bof_chart_version)
    finance_portal_chart_version          = try(var.common_var_map.finance_portal_chart_version, var.finance_portal_chart_version)
    ory_namespace                         = var.ory_namespace
    auth_fqdn                             = local.auth_fqdn
    keto_postgres_database                = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.database_name
    keto_postgres_user                    = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.username
    keto_postgres_host                    = "${local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    keto_postgres_password_secret         = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.user_password_secret
    keto_postgres_port                    = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_port
    keto_postgres_secret_path             = "${local.stateful_resources[local.keto_postgres_resource_index].local_resource_config.generate_secret_vault_base_path}/${local.stateful_resources[local.keto_postgres_resource_index].resource_name}/${local.stateful_resources[local.keto_postgres_resource_index].local_resource_config.generate_secret_name}-password"
    keto_postgres_password_secret_key     = "password"
    kratos_postgres_database              = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.database_name
    kratos_postgres_user                  = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.username
    kratos_postgres_host                  = "${local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kratos_postgres_password_secret       = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.user_password_secret
    kratos_postgres_port                  = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_port
    kratos_postgres_secret_path           = "${local.stateful_resources[local.kratos_postgres_resource_index].local_resource_config.generate_secret_vault_base_path}/${local.stateful_resources[local.kratos_postgres_resource_index].resource_name}/${local.stateful_resources[local.kratos_postgres_resource_index].local_resource_config.generate_secret_name}-password"
    kratos_postgres_password_secret_key   = "password"
    kratos_oidc_client_secret_secret_name = var.kratos_oidc_client_secret_secret
    kratos_oidc_client_id                 = var.kratos_oidc_client_id
    kratos_oidc_client_secret_secret_key  = var.kratos_oidc_client_secret_secret_key
    kratos_oidc_client_secret_secret_path = local.keycloak_secrets_path
    keycloak_kratos_realm_name            = var.keycloak_kratos_realm_name
    keycloak_name                         = var.keycloak_name
    keycloak_fqdn                         = local.keycloak_fqdn
    istio_external_gateway_namespace      = var.istio_external_gateway_namespace
    keycloak_namespace                    = var.keycloak_namespace
    istio_external_wildcard_gateway_name  = local.istio_external_wildcard_gateway_name
    test_user_name                        = "test1"
    test_user_password                    = "test1"
    bof_chart_version                     = try(var.app_var_map.bof_chart_version, var.bof_chart_version)
    bof_release_name                      = "ory-bof"
  }
  file_list       = [for f in fileset(local.ory_template_path, "**/*.yaml.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.ory_app_file, f))]
  template_path   = local.ory_template_path
  output_path     = "${var.output_dir}/ory"
  app_file        = local.ory_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "ory_stack_enabled" {
  description = "whether ory_stack app is enabled or not"
  type        = bool
  default     = true
}
variable "ory_sync_wave" {
  type        = string
  description = "ory_sync_wave"
  default     = "-2"
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
variable "bof_chart_version" {
  type        = string
  description = "bof_chart_version"
  default     = "4.0.0"
}
variable "finance_portal_chart_version" {
  type        = string
  description = "finance_portal_chart_version"
  default     = "4.0.0"
}
variable "ory_namespace" {
  type        = string
  description = "ory_namespace"
  default     = "ory"
}

variable "kratos_oidc_client_secret_secret" {
  type        = string
  description = "kratos_oidc_client_secret_secret"
  default     = "kratos-oidc-secret"
}

variable "kratos_oidc_client_secret_secret_key" {
  type        = string
  description = "kratos_oidc_client_secret_secret_key"
  default     = "secret"
}

variable "kratos_oidc_client_id" {
  type        = string
  description = "kratos_oidc_client_id"
  default     = "kratos"
}

variable "keycloak_kratos_realm_name" {
  type        = string
  description = "name of realm for dfsp api access"
  default     = "kratos"
}
variable "bof_chart_version" {
  type        = string
  description = "bof_chart_version for ory stack, should be renamed"
  default     = "3.0.1"
}

locals {
  ory_template_path              = "${path.module}/../generate-files/templates/ory"
  ory_app_file                   = "ory-app.yaml"
  kratos_postgres_resource_index = index(local.stateful_resources.*.resource_name, "kratos-db")
  keto_postgres_resource_index   = index(local.stateful_resources.*.resource_name, "keto-db")
  auth_fqdn                      = "auth.${var.public_subdomain}"
  oathkeeper_auth_url            = "oathkeeper-api.${var.ory_namespace}.svc.cluster.local"
  oathkeeper_auth_provider_name  = "ory-authz"
}
