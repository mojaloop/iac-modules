module "generate_velero_post_config_files" {
  source = "../generate-files"
  var_map = {
    velero_post_config_sync_wave   = var.velero_post_config_sync_wave
    gitlab_project_url             = var.gitlab_project_url
    velero_namespace               = var.velero_namespace
    velero_backup_schedule_name    = "${var.cluster_name}-backup"
    velero_backup_schedule         = var.velero_backup_schedule
    velero_backup_ttl              = var.velero_backup_ttl
    velero_backup_bucket_name      = local.velero_bucket
  }
  file_list       = [for f in fileset(local.velero_post_config_template_path, "**/*.tpl") : trimsuffix(f, ".tpl") if !can(regex(local.velero_post_config_app_file, f))]
  template_path   = local.velero_post_config_template_path
  output_path     = "${var.output_dir}/velero-post-config"
  app_file        = local.velero_post_config_app_file
  app_output_path = "${var.output_dir}/app-yamls"
}

locals {
  velero_post_config_template_path = "${path.module}/../generate-files/templates/velero-post-config"
  velero_post_config_app_file      = "velero-post-config-app.yaml"
}

variable "velero_post_config_sync_wave" {
  type        = string
  default     = "-7"
}

variable "velero_backup_schedule" {
  type        = string
  default     = "0 0 * * *"
}

variable "velero_backup_ttl" {
  type        = string
  default     = "720h0m0s"
}
