module "generate_velero_files" {
  source = "../generate-files"
  var_map = {
    velero_sync_wave           = var.velero_sync_wave
    gitlab_project_url             = var.gitlab_project_url
    velero_namespace               = var.velero_namespace
    velero_backup_bucket_name       = local.velero_bucket
    object_store_velero_credentials_secret_name = "velero-credentials-secret"
    object_store_region            = var.object_store_region
    object_store_velero_secret_key = "cloud"
    velero_plugin_version          = var.velero_plugin_version
    velero_helm_version            = var.velero_helm_version
  }
  file_list       = [for f in fileset(local.velero_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.velero_app_file, f))]
  template_path   = local.velero_template_path
  output_path     = "${var.output_dir}/velero"
  app_file        = local.velero_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  velero_template_path = "${path.module}/../generate-files/templates/velero"
  velero_app_file      = "velero-app.yaml"
}

variable "velero_sync_wave" {
  type        = string
  default     = "-8"
}

variable "velero_plugin_version" {
  type        = string
  default     = "v1.12.1"
}

variable "velero_helm_version" {
  type        = string
  default     = "10.0.1"
}
