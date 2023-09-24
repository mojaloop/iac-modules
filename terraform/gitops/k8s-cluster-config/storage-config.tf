module "generate_storage_files" {
  source = "./generate-files"
  var_map = {
    longhorn_chart_repo                              = var.longhorn_chart_repo
    longhorn_chart_version                           = var.longhorn_chart_version
    longhorn_credentials_secret                      = "longhorn-s3-credentials"
    cloud_region                                     = local.cloud_region
    longhorn_backups_bucket_name                     = local.longhorn_backups_bucket_name
    k8s_cluster_type                                 = local.k8s_cluster_type
    reclaim_policy                                   = var.longhorn_reclaim_policy
    replica_count                                    = var.longhorn_replica_count
    longhorn_backups_credentials_id_provider_key     = "${var.cluster_name}/${local.longhorn_backups_credentials_id_provider_key}"
    longhorn_backups_credentials_secret_provider_key = "${var.cluster_name}/${local.longhorn_backups_credentials_secret_provider_key}"
    gitlab_project_url                               = var.gitlab_project_url
    longhorn_namespace                               = var.longhorn_namespace
    external_secret_sync_wave                        = var.external_secret_sync_wave
    longhorn_job_sync_wave                           = var.longhorn_job_sync_wave
    storage_sync_wave                                = var.storage_sync_wave
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "external-secrets/longhorn-extsecret.yaml", "custom-resources/longhorn-job.yaml"]
  template_path   = "${path.module}/generate-files/templates/storage"
  output_path     = "${var.output_dir}/storage"
  app_file        = "storage-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}

variable "longhorn_chart_repo" {
  type        = string
  description = "longhorn_chart_repo"
  default     = "https://charts.longhorn.io"
}

variable "longhorn_chart_version" {
  type        = string
  description = "longhorn_chart_version"
  default     = "1.4.0"
}

variable "longhorn_reclaim_policy" {
  type        = string
  description = "longhorn_reclaim_policy"
  default     = "Retain"
}

variable "longhorn_replica_count" {
  type        = string
  description = "longhorn_replica_count"
  default     = "1"
}

variable "longhorn_namespace" {
  type        = string
  description = "longhorn_namespace"
  default     = "longhorn-system"
}

variable "storage_sync_wave" {
  type        = string
  description = "storage_sync_wave"
  default     = "-10"
}

variable "longhorn_job_sync_wave" {
  type        = string
  description = "longhorn_job_sync_wave"
  default     = "-9"
}
