module "generate_crossplane_files" {
  source = "../generate-files"
  var_map = {
    crossplane_sync_wave               = var.crossplane_sync_wave
    gitlab_project_url                 = var.gitlab_project_url
    external_secret_sync_wave          = var.external_secret_sync_wave
    cluster_name                       = var.cluster_name
    cloud_provider                     = var.cloud_platform
    crossplane_providers_k8s_version   = var.crossplane_providers_k8s_version
    crossplane_namespace               = var.crossplane_namespace
    crossplane_providers_vault_version = var.crossplane_providers_vault_version
    crossplane_packages_utils_version  = var.crossplane_packages_utils_version
    crossplane_helm_version            = var.crossplane_helm_version
  }
  file_list       = [for f in fileset(local.crossplane_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.crossplane_app_file, f))]
  template_path   = local.crossplane_template_path
  output_path     = "${var.output_dir}/crossplane"
  app_file        = local.crossplane_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  crossplane_template_path = "${path.module}/../generate-files/templates/crossplane"
  crossplane_app_file      = "crossplane-app.yaml"
}

variable "crossplane_sync_wave" {
  type        = string
  description = "crossplane_sync_wave"
  default     = "-10"
}

variable "crossplane_namespace" {
  type        = string
  default     = "crossplane-system"
}

variable "crossplane_helm_version" {
  type        = string
  default    = "1.19.0"
}

variable "crossplane_providers_vault_version" {
  type        = string
  description = "crossplane vault provider version"
  default = "2.1.1"
}

variable "crossplane_providers_k8s_version" {
  type        = string
  description = "crossplane k8s provider version"
  default = "0.11.4"
}

variable "crossplane_packages_utils_version" {
  type        = string
  description = "crossplane packages utils version"
  default = "v0.3.0-pr48-14533733180"
}