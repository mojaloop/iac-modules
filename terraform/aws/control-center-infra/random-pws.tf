resource "random_password" "gitlab_root_password" {
  length           = 16
  special          = true
  override_special = "_"
}

resource "random_password" "gitlab_root_token" {
  length           = 20
  special          = true
  override_special = "_"
}


resource "random_password" "gitlab_s3_access_secret" {
  length           = 20
  special          = true
  override_special = "_"
}

resource "random_password" "minio_root_password" {
  length  = 20
  special = false
}

resource "random_password" "admin_s3_access_secret" {
  length           = 20
  special          = true
  override_special = "_"
}

resource "random_password" "nexus_admin_password" {
  length           = 20
  special          = true
  override_special = "_"
}

resource "random_password" "netmaker_master_key" {
  length           = 30
  special          = true
  override_special = "_"
}

resource "random_password" "netmaker_mq_pw" {
  length           = 30
  special          = true
  override_special = "_"
}

resource "random_password" "netmaker_admin_password" {
  length           = 30
  special          = true
  override_special = "_"
}

resource "random_password" "mimir_minio_password" {
  length           = 20
  special          = true
  override_special = "_"
}

resource "random_password" "central_observability_grafana_root_password" {
  length  = 20
  special = true
}
