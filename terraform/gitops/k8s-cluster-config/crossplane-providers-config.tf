module "generate_crossplane_providers_files" {
  source = "../generate-files"
  var_map = {
    crossplane_providers_sync_wave     = var.crossplane_providers_sync_wave
    gitlab_project_url                 = var.gitlab_project_url
    crossplane_namespace               = var.crossplane_namespace
    crossplane_providers_k8s_version   = var.crossplane_providers_k8s_version
    crossplane_providers_vault_version = var.crossplane_providers_vault_version
  }
  file_list       = [for f in fileset(local.crossplane_providers_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.crossplane_providers_app_file, f))]
  template_path   = local.crossplane_providers_template_path
  output_path     = "${var.output_dir}/crossplane-providers"
  app_file        = local.crossplane_providers_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  crossplane_providers_template_path = "${path.module}/../generate-files/templates/crossplane-providers"
  crossplane_providers_app_file      = "crossplane-providers-app.yaml"
}

variable "crossplane_providers_sync_wave" {
  type        = string
  default     = "-12"
}

variable "crossplane_providers_vault_version" {
  type        = string
  description = "crossplane vault provider version"
}

variable "crossplane_providers_k8s_version" {
  type        = string
  description = "crossplane k8s provider version"
}