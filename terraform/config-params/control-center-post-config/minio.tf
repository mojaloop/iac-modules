# loki bucket , user and access policy 
resource "minio_s3_bucket" "loki-s3-bucket" {
  for_each      = var.env_map
  bucket        = "${each.key}-loki"
  force_destroy = true
}

resource "minio_ilm_policy" "loki-bucket-lifecycle-rules" {
  for_each = var.env_map
  bucket   = minio_s3_bucket.loki-s3-bucket[each.key].bucket
  rule {
    id         = "expire ${each.key}-loki"
    expiration = var.loki_data_expiry
  }
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
    env     = each.key
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
      "Action": "s3:*",
      "Resource": ["${minio_s3_bucket.loki-s3-bucket[each.key].arn}",
                  "${minio_s3_bucket.loki-s3-bucket[each.key].arn}/*"
                  ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "loki-policy-attachment" {
  for_each    = var.env_map
  user_name   = minio_iam_user.loki-user[each.key].id
  policy_name = minio_iam_policy.loki-iam-policy[each.key].id
}

resource "vault_kv_secret_v2" "minio-loki-password" {
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

resource "vault_kv_secret_v2" "minio-loki-username" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_loki_username"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = minio_iam_user.loki-user[each.key].name
    }
  )
}

# tempo bucket , user and access policy 
resource "minio_s3_bucket" "tempo-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-tempo"
}

resource "minio_ilm_policy" "tempo-bucket-lifecycle-rules" {
  for_each = var.env_map
  bucket   = minio_s3_bucket.tempo-s3-bucket[each.key].bucket
  rule {
    id         = "expire-${var.tempo_data_expiry_days}"
    expiration = var.tempo_data_expiry_days
  }
}

resource "random_password" "minio_tempo_password" {
  for_each = var.env_map
  length   = 20
  special  = false
}

resource "minio_iam_user" "tempo-user" {
  for_each      = var.env_map
  name          = "${each.key}-tempo-user"
  secret        = random_password.minio_tempo_password[each.key].result
  force_destroy = true
  tags = {
    env     = each.key
    purpose = "access tempo data"
  }
}

resource "minio_iam_policy" "tempo-iam-policy" {
  for_each = var.env_map
  name     = "${each.key}-tempo-policy"
  policy   = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"AccessEnvtempoBucket",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": ["${minio_s3_bucket.tempo-s3-bucket[each.key].arn}",
                  "${minio_s3_bucket.tempo-s3-bucket[each.key].arn}/*"
                  ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "tempo-policy-attachment" {
  for_each    = var.env_map
  user_name   = minio_iam_user.tempo-user[each.key].id
  policy_name = minio_iam_policy.tempo-iam-policy[each.key].id
}


resource "vault_kv_secret_v2" "minio-tempo-password" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_tempo_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = random_password.minio_tempo_password[each.key].result
    }
  )
}

resource "vault_kv_secret_v2" "minio-tempo-username" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_tempo_username"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = minio_iam_user.tempo-user[each.key].name
    }
  )
}

resource "gitlab_project_variable" "minio_tempo_bucket" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_tempo_bucket"
  value     = minio_s3_bucket.tempo-s3-bucket[each.key].id
  protected = false
  masked    = false
}



# longhorn bucket , user and access policy 
resource "minio_s3_bucket" "longhorn-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-longhorn-backup"
}

resource "minio_ilm_policy" "longhorn-bucket-lifecycle-rules" {
  for_each = var.env_map
  bucket   = minio_s3_bucket.longhorn-s3-bucket[each.key].bucket
  rule {
    id         = "expire ${each.key}-longhorn"
    expiration = var.longhorn_backup_data_expiry
  }
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
    env     = each.key
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
      "Action": "s3:*",
      "Resource": ["${minio_s3_bucket.longhorn-s3-bucket[each.key].arn}",
                   "${minio_s3_bucket.longhorn-s3-bucket[each.key].arn}/*"
                  ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "longhorn-policy-attachment" {
  for_each    = var.env_map
  user_name   = minio_iam_user.longhorn-user[each.key].id
  policy_name = minio_iam_policy.longhorn-iam-policy[each.key].id
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

resource "vault_kv_secret_v2" "minio-longhorn-username" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_longhorn_username"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = minio_iam_user.longhorn-user[each.key].name
    }
  )
}


# velero bucket , user and access policy 
resource "minio_s3_bucket" "velero-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-velero"
}

resource "minio_ilm_policy" "velero-bucket-lifecycle-rules" {
  for_each = var.env_map
  bucket   = minio_s3_bucket.velero-s3-bucket[each.key].bucket
  rule {
    id         = "expire-${var.velero_data_expiry}"
    expiration = var.velero_data_expiry
  }
}

resource "random_password" "minio_velero_password" {
  for_each = var.env_map
  length   = 20
  special  = false
}

resource "minio_iam_user" "velero-user" {
  for_each      = var.env_map
  name          = "${each.key}-velero-user"
  secret        = random_password.minio_velero_password[each.key].result
  force_destroy = true
  tags = {
    env     = each.key
    purpose = "access velero data"
  }
}

resource "minio_iam_policy" "velero-iam-policy" {
  for_each = var.env_map
  name     = "${each.key}-velero-policy"
  policy   = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"AccessEnvveleroBucket",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": ["${minio_s3_bucket.velero-s3-bucket[each.key].arn}",
                  "${minio_s3_bucket.velero-s3-bucket[each.key].arn}/*"
                  ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "velero-policy-attachment" {
  for_each    = var.env_map
  user_name   = minio_iam_user.velero-user[each.key].id
  policy_name = minio_iam_policy.velero-iam-policy[each.key].id
}


resource "vault_kv_secret_v2" "minio-velero-password" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_velero_password"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = random_password.minio_velero_password[each.key].result
    }
  )
}

resource "vault_kv_secret_v2" "minio-velero-username" {
  for_each            = var.env_map
  mount               = vault_mount.kv_secret.path
  name                = "${each.key}/minio_velero_username"
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = minio_iam_user.velero-user[each.key].name
    }
  )
}

resource "gitlab_project_variable" "minio_velero_bucket" {
  for_each  = var.env_map
  project   = gitlab_project.envs[each.key].id
  key       = "minio_velero_bucket"
  value     = minio_s3_bucket.velero-s3-bucket[each.key].id
  protected = false
  masked    = false
}