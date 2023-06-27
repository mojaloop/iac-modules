output "secrets_var_map" {
  sensitive = true
  value = {
    route53_external_dns_access_key = aws_iam_access_key.route53-external-dns.id
    route53_external_dns_secret_key = aws_iam_access_key.route53-external-dns.secret
    longhorn_backups_access_key     = aws_iam_access_key.longhorn_backups.id
    longhorn_backups_secret_key     = aws_iam_access_key.longhorn_backups.secret
  }
}

output "properties_var_map" {
  value = {
    longhorn_backups_bucket_name = aws_s3_bucket.longhorn_backups.bucket
  }
}

output "post_config_key_map" {
  value = {
    longhorn_backups_bucket_name_key = "longhorn_backups_bucket_name"
    external_dns_cred_id_key         = "route53_external_dns_access_key"
    external_dns_cred_secret_key     = "route53_external_dns_secret_key"
    longhorn_backups_cred_id_key     = "longhorn_backups_access_key"
    longhorn_backups_cred_secret_key = "longhorn_backups_secret_key"
  }
}
