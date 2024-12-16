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


data "gitlab_project_variable" "cert_manager_credentials_client_secret_name" {
  project = var.current_gitlab_project_id
  key     = var.properties_key_map["cert_manager_credentials_client_secret_name_key"]
}

data "gitlab_project_variable" "cert_manager_credentials_client_id_name" {
  project = var.current_gitlab_project_id
  key     = var.properties_key_map["cert_manager_credentials_client_id_name_key"]
}

data "gitlab_project_variable" "external_dns_credentials_client_secret_name" {
  project = var.current_gitlab_project_id
  key     = var.properties_key_map["external_dns_credentials_client_secret_name_key"]
}

data "gitlab_project_variable" "external_dns_credentials_client_id_name" {
  project = var.current_gitlab_project_id
  key     = var.properties_key_map["external_dns_credentials_client_id_name_key"]
}

# need to get these by hand because loki doesnt support k8s secret env vars.

data "vault_kv_secret_v2" "grafana_oauth_client_id" {
  count = var.enable_grafana_oidc ? 1 : 0  
  mount = var.kv_path
  name  = "${var.cluster_name}/${var.grafana_oidc_client_id_secret_key}"
}  

data "vault_kv_secret_v2" "grafana_oauth_client_secret" {
  count = var.enable_grafana_oidc ? 1 : 0  
  mount = var.kv_path
  name  = "${var.cluster_name}/${var.grafana_oidc_client_secret_secret_key}"
}  

data "gitlab_project_variable" "ceph_loki_bucket" {
  project = var.current_gitlab_project_id
  key     = "ceph_loki_bucket"
}

data "gitlab_project_variable" "ceph_tempo_bucket" {
  project = var.current_gitlab_project_id
  key     = "ceph_tempo_bucket"
}

data "gitlab_project_variable" "ceph_longhorn_bucket" {
  project = var.current_gitlab_project_id
  key     = "ceph_longhorn_backup_bucket"
}

data "gitlab_project_variable" "ceph_velero_bucket" {
  project = var.current_gitlab_project_id
  key     = "ceph_velero_bucket"
}

data "gitlab_project_variable" "ceph_percona_backup_bucket" {
  project = var.current_gitlab_project_id
  key     = "ceph_percona_bucket"
}