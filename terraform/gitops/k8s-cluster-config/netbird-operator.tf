module "generate_netbird_operator_files" {
  source = "../generate-files"
  var_map = {
    netbird_operator_sync_wave          = var.netbird_operator_sync_wave
    netbird_operator_namespace          = var.netbird_operator_namespace
    netbird_operator_api_key_vault_path = var.netbird_operator_api_key_vault_path
    netbird_operator_management_url     = var.netbird_operator_management_url
    netbird_operator_api_key_secret     = var.netbird_operator_api_key_secret
    netbird_operator_helm_version       = var.netbird_operator_helm_version
    external_secret_sync_wave           = var.external_secret_sync_wave
    gitlab_project_url                  = var.gitlab_project_url
  }

  file_list       = [for f in fileset(local.netbird_operator_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.netbird_operator_app_file, f))]
  template_path   = local.netbird_operator_template_path
  output_path     = "${var.output_dir}/netbird_operator"
  app_file        = local.netbird_operator_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  netbird_operator_template_path = "${path.module}/../generate-files/templates/netbird-operator"
  netbird_operator_app_file      = "netbird-operator-app.yaml"
}

variable "netbird_operator_sync_wave" {
  type        = string
  description = "netbird_operator_sync_wave"
  default     = "-7"
}

variable "netbird_operator_namespace" {
  type        = string
  description = "netbird_operator_namespace"
  default     = "netbird-operator"
}

variable "netbird_operator_api_key_secret" {
  type        = string
  description = "netbird_operator_api_key_secret"
  default     = "netbird-operator-api-key"
}

variable "netbird_operator_api_key_vault_path" {
  type        = string
  description = "netbird_operator_api_key_vault_path"
  default     = "env/access-token"
}

variable "netbird_operator_management_url" {
  type        = string
  description = "url to connect to management netbird instance"
}

variable "netbird_operator_helm_version" {
  type        = string
  description = "netbird_operator_helm_version"
  default     = "0.1.10"
}
