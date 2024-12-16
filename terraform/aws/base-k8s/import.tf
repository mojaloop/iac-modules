import {
  for_each = var.backup_bucket_import_enabled ? [1] : []
  id  = "${var.domain}-${var.backup_bucket_name}"
  to  = module.post_config.aws_s3_bucket.backup_bucket
}