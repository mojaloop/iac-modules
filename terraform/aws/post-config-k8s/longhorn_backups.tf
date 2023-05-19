resource "aws_s3_bucket" "longhorn_backups" {
  bucket = "${local.base_domain}-lhbck"
  force_destroy = var.longhorn_backup_s3_destroy
  tags = merge({ Name = "${var.name}-longhorn_backups" }, var.tags)
}
resource "aws_s3_bucket_ownership_controls" "longhorn_backups" {
  bucket = aws_s3_bucket.longhorn_backups.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "longhorn_backups" {
  depends_on = [aws_s3_bucket_ownership_controls.longhorn_backups]

  bucket = aws_s3_bucket.longhorn_backups.id
  acl    = "private"
}

resource "aws_iam_user" "longhorn_backups" {
  name = "${local.base_domain}-lhbck"
  tags = merge({ Name = "${var.name}-longhorn_backups" }, var.tags)
}
resource "aws_iam_access_key" "longhorn_backups" {
  user = aws_iam_user.longhorn_backups.name
}
# IAM Policy to allow longhorn store objects
resource "aws_iam_user_policy" "longhorn_backups" {
  name = "${local.base_domain}-lhbck"
  user = aws_iam_user.longhorn_backups.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GrantLonghornBackupstoreAccess0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${local.base_domain}-lhbck",
                "arn:aws:s3:::${local.base_domain}-lhbck/*"
            ]
        }
    ]
}
EOF
}
