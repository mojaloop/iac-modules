module "generate_crossplane_packages_files" {
  source = "../generate-files"
  var_map = {
    crossplane_packages_sync_wave           = var.crossplane_packages_sync_wave
    gitlab_project_url                      = var.gitlab_project_url
    crossplane_namespace                    = var.crossplane_namespace
    crossplane_packages_utils_version       = var.crossplane_packages_utils_version
    crossplane_functions_kcl_version        = var.crossplane_functions_kcl_version
    crossplane_functions_auto_ready_version = var.crossplane_functions_auto_ready_version
    crossplane_functions_extra_resources_version = var.crossplane_functions_extra_resources_version
    crossplane_packages_aws_documentdb_version = var.crossplane_packages_aws_documentdb_version
    crossplane_packages_aws_rds_version        = var.crossplane_packages_aws_rds_version
  }
  file_list       = [for f in fileset(local.crossplane_packages_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.crossplane_packages_app_file, f))]
  template_path   = local.crossplane_packages_template_path
  output_path     = "${var.output_dir}/crossplane-packages"
  app_file        = local.crossplane_packages_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  crossplane_packages_template_path = "${path.module}/../generate-files/templates/crossplane-packages"
  crossplane_packages_app_file      = "crossplane-packages-app.yaml"
}

variable "crossplane_packages_sync_wave" {
  type        = string
  default     = "-11"
}

variable "crossplane_packages_utils_version" {
  type        = string
}

variable "crossplane_packages_aws_documentdb_version" {
  type        = string
}


variable "crossplane_packages_aws_rds_version" {
  type        = string
}


variable "crossplane_functions_kcl_version" {
  type        = string
}

variable "crossplane_functions_auto_ready_version" {
  type        = string
}

variable "crossplane_functions_extra_resources_version" {
  type        = string
}
