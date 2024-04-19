resource "minio_s3_bucket" "tempo-s3-bucket" {
  for_each = var.env_map
  bucket   = "${each.key}-tempo"
}

resource "minio_ilm_policy" "tempo-bucket-lifecycle-rules" {
  for_each = var.env_map
  bucket = minio_s3_bucket.tempo-s3-bucket[each.key].bucket
  rule {
    id         = "expire-${tempo_data_expiry_days}"
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
    env  = each.key
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


