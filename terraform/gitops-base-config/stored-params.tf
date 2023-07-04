data "gitlab_project_variable" "k8s_cluster_type" {
  project = var.current_gitlab_project_id
  key     = "K8S_CLUSTER_TYPE"
}

data "gitlab_project_variable" "cloud_platform" {
  project = var.current_gitlab_project_id
  key     = "CLOUD_PLATFORM"
}

data "gitlab_project_variable" "cloud_region" {
  project = var.current_gitlab_project_id
  key     = "CLOUD_REGION"
}

data "gitlab_project_variable" "longhorn_backups_bucket_name" {
  project = var.current_gitlab_project_id
  key     = var.properties_key_map["longhorn_backups_bucket_name_key"]
}

# need to get these by hand because loki doesnt support k8s secret env vars.

data "vault_generic_secret" "grafana_oauth_client_id" {
  path = "${var.kv_path}/${var.cluster_name}/${var.grafana_oidc_client_id_secret_key}"
}

data "vault_generic_secret" "grafana_oauth_client_secret" {
  path = "${var.kv_path}/${var.cluster_name}/${var.grafana_oidc_client_secret_secret_key}"
}
