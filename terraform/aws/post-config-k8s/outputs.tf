output "secrets_var_map" {
  sensitive = true
  value = {
    route53_external_dns_access_key = aws_iam_access_key.route53-external-dns.id
    route53_external_dns_secret_key = aws_iam_access_key.route53-external-dns.secret
  }
}

output "properties_var_map" {
  value = {
    external_dns_credentials_client_id_name     = "AWS_ACCESS_KEY_ID"
    external_dns_credentials_client_secret_name = "AWS_SECRET_ACCESS_KEY"
    cert_manager_credentials_client_id_name     = "AWS_ACCESS_KEY_ID"
    cert_manager_credentials_client_secret_name = "AWS_SECRET_ACCESS_KEY"
  }
}

output "post_config_secrets_key_map" {
  value = {
    external_dns_cred_id_key         = "route53_external_dns_access_key"
    external_dns_cred_secret_key     = "route53_external_dns_secret_key"
  }
}

output "post_config_properties_key_map" {
  value = {
    external_dns_credentials_client_id_name_key     = "external_dns_credentials_client_id_name"
    external_dns_credentials_client_secret_name_key = "external_dns_credentials_client_secret_name"
    cert_manager_credentials_client_id_name_key     = "cert_manager_credentials_client_id_name"
    cert_manager_credentials_client_secret_name_key = "cert_manager_credentials_client_secret_name"
  }
}
