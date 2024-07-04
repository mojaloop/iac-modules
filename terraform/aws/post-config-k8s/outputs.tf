output "secrets_var_map" {
  sensitive = true
  value = merge(var.create_iam_user ? {
    iac_user_key_id     = aws_iam_access_key.ci_iam_user_key[0].id
    iac_user_key_secret = aws_iam_access_key.ci_iam_user_key[0].secret
    } : {}, var.create_ext_dns_user ? {
    route53_external_dns_access_key = aws_iam_access_key.route53-external-dns[0].id
    route53_external_dns_secret_key = aws_iam_access_key.route53-external-dns[0].secret
  } : {})
}

output "properties_var_map" {
  value = merge(var.create_iam_user ? {
    ci_user_client_id_name     = "AWS_ACCESS_KEY_ID"
    ci_user_client_secret_name = "AWS_SECRET_ACCESS_KEY"
    } : {}, var.create_ext_dns_user ? {
    external_dns_credentials_client_id_name     = "AWS_ACCESS_KEY_ID"
    external_dns_credentials_client_secret_name = "AWS_SECRET_ACCESS_KEY"
    cert_manager_credentials_client_id_name     = "AWS_ACCESS_KEY_ID"
    cert_manager_credentials_client_secret_name = "AWS_SECRET_ACCESS_KEY"
  } : {})
}

output "post_config_secrets_key_map" {
  value = merge(var.create_iam_user ? {
    iac_user_cred_id_key     = "iac_user_key_id"
    iac_user_cred_secret_key = "iac_user_key_secret"
    } : {}, var.create_ext_dns_user ? {
    external_dns_cred_id_key     = "route53_external_dns_access_key"
    external_dns_cred_secret_key = "route53_external_dns_secret_key"
  } : {})
}

output "post_config_properties_key_map" {
  value = merge(var.create_iam_user ? {
    ci_user_client_id_name_key     = "ci_user_client_id_name"
    ci_user_client_secret_name_key = "ci_user_client_secret_name"
    } : {}, var.create_ext_dns_user ? {
    external_dns_credentials_client_id_name_key     = "external_dns_credentials_client_id_name"
    external_dns_credentials_client_secret_name_key = "external_dns_credentials_client_secret_name"
    cert_manager_credentials_client_id_name_key     = "cert_manager_credentials_client_id_name"
    cert_manager_credentials_client_secret_name_key = "cert_manager_credentials_client_secret_name"
  } : {})
}

output "ext_dns_cloud_policy" {
  value = aws_iam_policy.route53_external_dns.arn
}
