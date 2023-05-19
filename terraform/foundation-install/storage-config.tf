module "generate_storage_files" {
  source = "./generate-files"
  var_map = {
    longhorn_chart_repo                    = var.longhorn_chart_repo
    longhorn_chart_version                 = var.longhorn_chart_version
    longhorn_credentials_secret            = var.longhorn_credentials_secret
    cloud_region                           = local.cloud_region
    longhorn_backups_bucket_name           = var.longhorn_backups_bucket_name
    k8s_cluster_type                       = local.k8s_cluster_type
    reclaim_policy                         = var.longhorn_reclaim_policy
    replica_count                          = var.longhorn_replica_count
    gitlab_key_longhorn_backups_access_key = var.gitlab_key_longhorn_backups_access_key
    gitlab_key_longhorn_backups_secret_key = var.gitlab_key_longhorn_backups_secret_key
    gitops_project_path_prefix             = var.gitops_project_path_prefix
    gitlab_project_url                     = var.gitlab_project_url
    longhorn_namespace                     = var.longhorn_namespace
    external_secret_sync_wave              = var.external_secret_sync_wave
    longhorn_job_sync_wave                 = var.longhorn_job_sync_wave
  }
  file_list       = ["chart/Chart.yaml", "chart/values.yaml", "external-secrets/longhorn-extsecret.yaml", "custom-resources/longhorn-job.yaml"]
  template_path   = "${path.module}/generate-files/templates/storage"
  output_path     = "${var.output_dir}/storage"
  app_file        = "storage-app.yaml"
  app_output_path = "${var.output_dir}/app-yamls"
}
