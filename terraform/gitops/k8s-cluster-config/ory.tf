module "generate_ory_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                    = var.gitlab_project_url
    ory_sync_wave                         = var.ory_sync_wave
    oathkeeper_chart_version              = var.oathkeeper_chart_version
    kratos_chart_version                  = var.kratos_chart_version
    keto_chart_version                    = var.keto_chart_version
    ory_namespace                         = var.ory_namespace
    auth_fqdn                             = local.kratos_fqdn
    keto_postgres_database                = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.database_name
    keto_postgres_user                    = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.username
    keto_postgres_host                    = "${local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    keto_postgres_password_secret         = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.user_password_secret
    keto_postgres_port                    = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_port
    keto_postgres_secret_path             = "${local.stateful_resources[local.keto_postgres_resource_index].local_resource_config.generate_secret_vault_base_path}/${local.stateful_resources[local.keto_postgres_resource_index].local_resource_config.generate_secret_name}-password"
    keto_postgres_password_secret_key     = "password"
    kratos_postgres_database              = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.database_name
    kratos_postgres_user                  = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.username
    kratos_postgres_host                  = "${local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kratos_postgres_password_secret       = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.user_password_secret
    kratos_postgres_port                  = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_port
    kratos_postgres_secret_path           = "${local.stateful_resources[local.kratos_postgres_resource_index].local_resource_config.generate_secret_vault_base_path}/${local.stateful_resources[local.kratos_postgres_resource_index].local_resource_config.generate_secret_name}-password"
    kratos_postgres_password_secret_key   = "password"
    kratos_oidc_client_secret_secret_name = var.kratos_oidc_client_secret_secret
    kratos_oidc_client_id                 = var.kratos_oidc_client_id
    kratos_oidc_client_secret_secret_key  = var.kratos_oidc_client_secret_secret_key
    kratos_oidc_client_secret_secret_path = local.keycloak_secrets_path
    keycloak_kratos_realm_name            = var.keycloak_kratos_realm_name
    keycloak_name                         = var.keycloak_name
    keycloak_fqdn                         = local.keycloak_fqdn
    keto_dsn_secretname                   = "keto-db-dsn-secret"
    kratos_dsn_secretname                 = "kratos-db-dsn-secret"
    istio_external_gateway_namespace      = var.istio_external_gateway_namespace
    keycloak_namespace                    = var.keycloak_namespace
    istio_external_wildcard_gateway_name  = local.istio_external_wildcard_gateway_name
  }
  file_list       = ["kustomization.yaml", "values-keto.yaml", "values-kratos.yaml", "values-oathkeeper.yaml", "vault-secret.yaml", "istio-config.yaml", "keycloak-realm-cr.yaml"]
  template_path   = "${path.module}/../generate-files/templates/ory"
  output_path     = "${var.output_dir}/ory"
  app_file        = "ory-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "ory_sync_wave" {
  type        = string
  description = "ory_sync_wave"
  default     = "-2"
}
variable "oathkeeper_chart_version" {
  type        = string
  description = "oathkeeper_chart_version"
  default     = "0.38.1"
}
variable "kratos_chart_version" {
  type        = string
  description = "kratos_chart_version"
  default     = "0.38.1"
}
variable "keto_chart_version" {
  type        = string
  description = "keto_chart_version"
  default     = "0.38.1"
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

locals {
  kratos_postgres_resource_index = index(local.stateful_resources.*.resource_name, "kratos-db")
  keto_postgres_resource_index   = index(local.stateful_resources.*.resource_name, "keto-db")
  kratos_fqdn                    = "kratos.${var.public_subdomain}"
}
