
resource "minio_s3_bucket" "mimir-s3-bucket" {
  bucket = "central-observability-mimir"
}

resource "minio_ilm_policy" "mimir-bucket-lifecycle-rules" {
  bucket = minio_s3_bucket.mimir-s3-bucket.bucket
  rule {
    id         = "expire central-observability-mimir"
    expiration = var.mimir_data_expiry
  }
}

resource "random_password" "minio-mimir-password" {
  length  = 20
  special = false
}

resource "minio_iam_user" "minio-mimir-user" {
  name          = "central-observability-mimir-user"
  secret        = random_password.minio_mimir_password.result
  force_destroy = true
}

resource "minio_iam_policy" "mimir-iam-policy" {
  name   = "central-observability-mimir-policy"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Sid":"AccessMimirBucket",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": ["${minio_s3_bucket.mimir-s3-bucket.arn}",
                  "${minio_s3_bucket.mimir-s3-bucket.arn}/*"
                  ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "mimir-policy-attachment" {
  user_name   = minio_iam_user.mimir-user.id
  policy_name = minio_iam_policy.mimir-iam-policy.id
}


