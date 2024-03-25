# loki bucket , user and access policy 
resource "minio_s3_bucket" "loki-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-loki"
}

resource "random_password" "minio_loki_password" {
  for_each = var.env_map
  length   = 20
  special  = false
}

resource "minio_iam_user" "loki-user" {
  for_each      = var.env_map
  name          = "${each.key}-loki-user"
  secret        = random_password.minio_loki_password[each.key].result
  force_destroy = true
  tags = {
    env  = each.key
    purpose = "loki data"
  }
}

resource "minio_iam_policy" "loki-iam-policy" {
  for_each = var.env_map
  name     = "${each.key}-loki-policy"
  policy   = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"AccessEnvLokiBucket",
      "Effect": "Allow",
      "Action": ["*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.loki-s3-bucket[each.key].arn}"]
    }
  ]
}
EOF
}

resource "vault_kv_secret_v2" "minio-loki-secret" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_loki_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = random_password.minio_loki_password[each.key].result
    }
  )
}

resource "gitlab_project_variable" "minio_loki_bucket" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_loki_bucket"
  value     = minio_s3_bucket.loki-s3-bucket[each.key].id
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "minio_loki_user" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_loki_user"
  value     = minio_iam_user.loki-user[each.key].name
  protected = false
  masked    = false
}

# longhorn bucket , user and access policy 
resource "minio_s3_bucket" "longhorn-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-longhorn-backup"
}

resource "random_password" "minio_longhorn_password" {
  for_each = var.env_map
  length   = 20
  special  = false
}

resource "minio_iam_user" "longhorn-user" {
  for_each      = var.env_map
  name          = "${each.key}-longhorn-user"
  secret        = random_password.minio_longhorn_password[each.key].result
  force_destroy = true
  tags = {
    env  = each.key
    purpose = "longhorn backup"
  }
}

resource "minio_iam_policy" "longhorn-iam-policy" {
  for_each = var.env_map
  name     = "${each.key}-longhorn-policy"
  policy   = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"AccessEnvlonghornBucket",
      "Effect": "Allow",
      "Action": ["*"],
      "Principal":"*",
      "Resource": ["${minio_s3_bucket.longhorn-s3-bucket[each.key].arn}"]
    }
  ]
}
EOF
}

resource "vault_kv_secret_v2" "minio-longhorn-secret" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_longhorn_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = random_password.minio_longhorn_password[each.key].result
    }
  )
}

resource "gitlab_project_variable" "minio_longhorn_bucket" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_longhorn_bucket"
  value     = minio_s3_bucket.longhorn-s3-bucket[each.key].id
  protected = false
  masked    = false
}

resource "gitlab_project_variable" "minio_longhorn_user" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_longhorn_user"
  value     = minio_iam_user.longhorn-user[each.key].name
  protected = false
  masked    = false
}