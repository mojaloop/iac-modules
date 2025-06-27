data "kubernetes_secret_v1" "loki_bucket" {
  metadata {
      name      = "${var.env_name}-loki"
      namespace = var.env_name
  }
}

resource "vault_kv_secret_v2" "loki_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/loki_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.loki_bucket.data.username, "")
    }
  )
}

resource "vault_kv_secret_v2" "loki_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/loki_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.loki_bucket.data.password, "")
    }
  )
}


data "kubernetes_secret_v1" "tempo_bucket" {
  metadata {
      name      = "${var.env_name}-tempo"
      namespace = var.env_name
  }
}

resource "vault_kv_secret_v2" "tempo_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/tempo_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.tempo_bucket.data.username, "")
    }
  )
}

resource "vault_kv_secret_v2" "tempo_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/tempo_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.tempo_bucket.data.password, "")
    }
  )
}


data "kubernetes_secret_v1" "velero_bucket" {
  metadata {
      name      = "${var.env_name}-velero"
      namespace = var.env_name
  }
}

resource "vault_kv_secret_v2" "velero_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/velero_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.velero_bucket.data.username, "")
    }
  )
}

resource "vault_kv_secret_v2" "velero_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/velero_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.velero_bucket.data.password, "")
    }
  )
}

data "kubernetes_secret_v1" "percona_bucket" {
  metadata {
      name      = "${var.env_name}-percona"
      namespace = var.env_name
  }
}

resource "vault_kv_secret_v2" "percona_bucket_access_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/percona_bucket_access_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.percona_bucket.data.username, "")
    }
  )
}

resource "vault_kv_secret_v2" "percona_bucket_secret_key_id" {
  mount               = var.kv_path
  name                = "${var.env_name}/percona_bucket_secret_key_id"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = try(data.kubernetes_secret_v1.percona_bucket.data.password, "")
    }
  )
}

data "gitlab_project" "env" {
  path_with_namespace = "iac/${var.env_name}"
}

resource "gitlab_project_variable" "bucket" {
  for_each  = local.env_buckets
  project   = data.gitlab_project.env.id
  key       = "${each.key}_bucket"
  value     = "${each.value}-${var.env_name}-${var.hyphenated_domain}"
  protected = false
  masked    = false
}