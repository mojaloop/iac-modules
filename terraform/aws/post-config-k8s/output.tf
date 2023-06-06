output "longhorn_backups_bucket_name" {
  value = aws_s3_bucket.longhorn_backups.bucket
}

output "gitlab_key_route53_external_dns_access_key" {
  value = gitlab_project_variable.route53_external_dns_access_key.key
}

output "gitlab_key_route53_external_dns_secret_key" {
  value = gitlab_project_variable.route53_external_dns_secret_key.key
}

output "gitlab_key_longhorn_backups_access_key" {
  value = gitlab_project_variable.longhorn_backups_access_key.key
}

output "gitlab_key_longhorn_backups_secret_key" {
  value = gitlab_project_variable.longhorn_backups_secret_key.key
}

output "gitlab_key_vault_iam_user_access_key" {
  value = gitlab_project_variable.vault_iam_user_access_key.key
}

output "gitlab_key_vault_iam_user_secret_key" {
  value = gitlab_project_variable.vault_iam_user_secret_key.key
}

output "vault_kms_seal_kms_key_id" {
  value = aws_kms_key.vault_unseal_key.id
}
output "netmaker_ops_token" {
  value = data.gitlab_project_variable.netmaker_ops_token.value
  sensitive = true
}

output "nexus_fqdn" {
  value = data.gitlab_group_variable.nexus_fqdn.value
}

output "nexus_docker_repo_listening_port" {
  value = data.gitlab_group_variable.nexus_docker_repo_listening_port.value
}

output "seaweedfs_fqdn" {
  value = data.gitlab_group_variable.seaweedfs_fqdn.value
}

output "seaweedfs_s3_listening_port" {
  value = data.gitlab_group_variable.seaweedfs_s3_listening_port.value
}