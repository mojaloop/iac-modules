module "generate_ory_files" {
  source = "../generate-files"
  var_map = {
    gitlab_project_url                  = var.gitlab_project_url
    ory_sync_wave                       = var.ory_sync_wave
    oathkeeper_chart_version            = var.oathkeeper_chart_version
    oathkeeper_maester_chart_version    = var.oathkeeper_maester_chart_version
    kratos_chart_version                = var.kratos_chart_version
    keto_chart_version                  = var.keto_chart_version
    ory_namespace                       = var.ory_namespace
    keto_postgres_database              = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.database_name
    keto_postgres_user                  = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.username
    keto_postgres_host                  = "${local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    keto_postgres_password_secret       = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.user_password_secret
    keto_postgres_port                  = local.stateful_resources[local.keto_postgres_resource_index].logical_service_config.logical_service_port
    keto_postgres_password_secret_key   = "password"
    kratos_postgres_database            = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.database_name
    kratos_postgres_user                = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.username
    kratos_postgres_host                = "${local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_name}.${var.stateful_resources_namespace}.svc.cluster.local"
    kratos_postgres_password_secret     = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.user_password_secret
    kratos_postgres_port                = local.stateful_resources[local.kratos_postgres_resource_index].logical_service_config.logical_service_port
    kratos_postgres_password_secret_key = "password"
  }
  file_list       = ["kustomization.yaml", "values-keto.yaml", "values-kratos.yaml", "values-oathkeeper.yaml", "values-oathkeeper-maester.yaml", "vault-secret.yaml"]
  template_path   = "${path.module}/../generate-files/templates/ory"
  output_path     = "${var.output_dir}/ory"
  app_file        = "ory-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "ory_sync_wave" {
  type        = string
  description = "ory_sync_wave"
  default     = "-5"
}
variable "oathkeeper_chart_version" {
  type        = string
  description = "oathkeeper_chart_version"
  default     = "0.38.1"
}
variable "oathkeeper_maester_chart_version" {
  type        = string
  description = "oathkeeper_maester_chart_version"
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

locals {
  kratos_postgres_resource_index = index(local.stateful_resources.*.resource_name, "kratos-db")
  keto_postgres_resource_index   = index(local.stateful_resources.*.resource_name, "keto-db")
}
