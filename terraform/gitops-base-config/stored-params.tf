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
  key     = var.post_config_properties_key_map["longhorn_backups_bucket_name_key"]
}

resource "vault_mount" "kv_secret" {
  path                      = var.kv_path
  type                      = "kv-v2"
  options                   = { version = "2" }
  default_lease_ttl_seconds = "120"
}
# need to get these by hand because loki doesnt support k8s secret env vars.
data "vault_kv_secret_v2" "grafana_oauth_client_id" {
  mount = vault_mount.kv_secret
  name = "${var.cluster_name}/${var.grafana_oidc_client_id_secret_key}"
}

data "vault_kv_secret_v2" "grafana_oauth_client_secret" {
  mount = vault_mount.kv_secret
  name = "${var.cluster_name}/${var.grafana_oidc_client_secret_secret_key}"
}