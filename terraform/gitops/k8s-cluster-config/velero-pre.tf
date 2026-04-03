module "generate_velero_pre_files" {
  source = "../generate-files"
  var_map = {
    velero_pre_sync_wave           = var.velero_pre_sync_wave
    gitlab_project_url             = var.gitlab_project_url
    velero_namespace               = var.velero_namespace
    object_store_velero_credentials_secret_name = "velero-credentials-secret"
    object_store_region            = var.object_store_region
    object_store_velero_secret_key = "cloud"
    object_store_velero_user_key = "${var.cluster_name}/velero_bucket_access_key_id"
    object_store_velero_password_key = "${var.cluster_name}/velero_bucket_access_key_id"
  }
  file_list       = [for f in fileset(local.velero_pre_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.velero_pre_app_file, f))]
  template_path   = local.velero_pre_template_path
  output_path     = "${var.output_dir}/velero-pre"
  app_file        = local.velero_pre_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  velero_pre_template_path = "${path.module}/../generate-files/templates/velero-pre"
  velero_pre_app_file      = "velero-pre-app.yaml"
}

variable "velero_pre_sync_wave" {
  type        = string
  default     = "-10"
}

variable "velero_namespace" {
  type        = string
  default     = "velero"
}
