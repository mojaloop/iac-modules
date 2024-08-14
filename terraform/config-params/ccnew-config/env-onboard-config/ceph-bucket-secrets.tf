data "kubernetes_secret_v1" "loki_bucket" {
  metadata {
      "name"      = "${var.env_name}-loki-bucket"
      "namespace" = var.gitlab_namespace
  }
}

resource "vault_kv_secret_v2" "loki_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/loki_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.loki_bucket.data.AWS_ACCESS_KEY_ID
    }
  )
}

resource "vault_kv_secret_v2" "loki_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/loki_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.loki_bucket.data.AWS_SECRET_ACCESS_KEY
    }
  )
}



data "kubernetes_secret_v1" "tempo_bucket" {
  metadata {
      "name"      = "${var.env_name}-tempo-bucket"
      "namespace" = var.gitlab_namespace
  }
}

resource "vault_kv_secret_v2" "tempo_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/tempo_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.tempo_bucket.data.AWS_ACCESS_KEY_ID
    }
  )
}

resource "vault_kv_secret_v2" "tempo_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/tempo_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.tempo_bucket.data.AWS_SECRET_ACCESS_KEY
    }
  )
}

data "kubernetes_secret_v1" "longhorn_backup_bucket" {
  metadata {
      "name"      = "${var.env_name}-loki-bucket"
      "namespace" = var.gitlab_namespace
  }
}

resource "vault_kv_secret_v2" "longhorn_backup_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/longhorn_backup_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.longhorn_backup_bucket.data.AWS_ACCESS_KEY_ID
    }
  )
}

resource "vault_kv_secret_v2" "longhorn_backup_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/longhorn_backup_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.longhorn_backup_bucket.data.AWS_SECRET_ACCESS_KEY
    }
  )
}

data "kubernetes_secret_v1" "velero_bucket" {
  metadata {
      "name"      = "${var.env_name}-velero-bucket"
      "namespace" = var.gitlab_namespace
  }
}

resource "vault_kv_secret_v2" "velero_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/velero_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.velero_bucket.data.AWS_ACCESS_KEY_ID
    }
  )
}

resource "vault_kv_secret_v2" "velero_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/velero_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.velero_bucket.data.AWS_SECRET_ACCESS_KEY
    }
  )
}

data "kubernetes_secret_v1" "percona_bucket" {
  metadata {
      "name"      = "${var.env_name}-percona-bucket"
      "namespace" = var.gitlab_namespace
  }
}

resource "vault_kv_secret_v2" "percona_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/percona_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.percona_bucket.data.AWS_ACCESS_KEY_ID
    }
  )
}

resource "vault_kv_secret_v2" "percona_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/percona_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = data.kubernetes_secret_v1.percona_bucket.data.AWS_SECRET_ACCESS_KEY
    }
  )
}